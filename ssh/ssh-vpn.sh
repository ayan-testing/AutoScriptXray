#!/bin/bash

# === Logging Functions ===
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"
log_info()    { echo -e "${GREEN}[ Info ]${NC} $1"; }
log_error()   { echo -e "${RED}[ Error ]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[ Warning ]${NC} $1"; }

# === Basic Setup ===
export DEBIAN_FRONTEND=noninteractive
if [[ ! -f /etc/AutoScriptXray/domain ]]; then
    log_error "/etc/AutoScriptXray/domain not found. Exiting."
    exit 1
fi
domain=$(cat /etc/AutoScriptXray/domain)

log_info "Updating system and removing unwanted packages..."
apt update -y > /dev/null 2>&1 && apt dist-upgrade -y > /dev/null 2>&1
if [[ $? -ne 0 ]]; then log_error "System update failed."; exit 1; fi
apt-get purge -y ufw firewalld exim4 samba* apache2* bind9* sendmail* unscd > /dev/null 2>&1 || log_warning "Some packages could not be purged (may not be installed)."
apt autoremove -y > /dev/null 2>&1 && apt autoclean -y > /dev/null 2>&1

log_info "Installing essential packages..."
apt install -y \
  netfilter-persistent screen curl jq bzip2 gzip vnstat coreutils rsyslog \
  iftop zip unzip git apt-transport-https build-essential \
  python3 make net-tools nano sed gnupg bc dirmngr \
  lsof libz-dev gcc g++ \
  zlib1g-dev libssl-dev dos2unix fail2ban \
  shc wget stunnel4 nginx socat xz-utils > /dev/null 2>&1
if [[ $? -ne 0 ]]; then log_error "Failed to install one or more essential packages."; exit 1; fi

sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

log_info "Disabling IPv6..."
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system > /dev/null 2>&1 || log_warning "Failed to reload sysctl settings."

log_info "Configuring SSH..."
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
for port in 22 200; do
    sed -i "/Port 22/a Port $port" /etc/ssh/sshd_config
done
/etc/init.d/ssh restart > /dev/null 2>&1 || log_warning "Failed to restart SSH."

log_info "Configuring Dropbear..."
apt install -y dropbear > /dev/null 2>&1 || log_error "Failed to install Dropbear."
sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/' /etc/default/dropbear
sed -i 's|DROPBEAR_EXTRA_ARGS=.*|DROPBEAR_EXTRA_ARGS="-p 109 -p 69"|' /etc/default/dropbear
echo -e "/bin/false\n/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart > /dev/null 2>&1 || log_warning "Failed to restart Dropbear."

log_info "Setting up WebSocket-SSH Python service..."
# Download WebSocket-SSH Python script and service file
wget -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/sshws/ws-stunnel > /dev/null 2>&1 && chmod +x /usr/local/bin/ws-stunnel || log_warning "Failed to install ws-stunnel."
wget -O /etc/systemd/system/ws-stunnel.service https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/sshws/ws-stunnel.service > /dev/null 2>&1 && chmod +x /etc/systemd/system/ws-stunnel.service || log_warning "Failed to install ws-stunnel.service."

# Reload systemd and enable/start/restart service
systemctl daemon-reload > /dev/null 2>&1
systemctl enable ws-stunnel.service > /dev/null 2>&1
systemctl start ws-stunnel.service > /dev/null 2>&1
systemctl restart ws-stunnel.service > /dev/null 2>&1

log_info "Setting up Nginx..."
rm -f /etc/nginx/{sites-available/default,sites-enabled/default,conf.d/default.conf}
mkdir -p /home/vps/public_html
mkdir -p /etc/systemd/system/nginx.service.d

# Download Nginx configs and web files
files=(
  "nginx.conf:/etc/nginx/nginx.conf"
  "vps.conf:/etc/nginx/conf.d/vps.conf"
  "reverse-proxy.conf:/etc/nginx/conf.d/reverse-proxy.conf"
  "index:/home/vps/public_html/index.html"
)
for f in "${files[@]}"; do
    name="${f%%:*}"
    path="${f##*:}"
    wget -qO "$path" "https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/$name" || log_error "Failed to download $name."
done

cat > /etc/systemd/system/nginx.service.d/override.conf <<EOF
[Service]
ExecStartPost=/bin/sleep 0.1
EOF

systemctl daemon-reload > /dev/null 2>&1
systemctl restart nginx > /dev/null 2>&1 || log_error "Failed to restart Nginx."

log_info "Setting up SSL certificate with acme.sh..."
mkdir -p /root/.acme.sh
curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh || log_error "Failed to download acme.sh."
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade > /dev/null 2>&1
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt > /dev/null 2>&1
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256 > /dev/null 2>&1 || log_error "acme.sh certificate issue failed."
/root/.acme.sh/acme.sh --installcert -d "$domain" \
  --fullchainpath /etc/AutoScriptXray/cert.crt \
  --keypath /etc/AutoScriptXray/cert.key --ecc > /dev/null 2>&1 || log_error "acme.sh certificate install failed."

log_info "Setting up BadVPN..."
wget -qO /usr/bin/badvpn-udpgw https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/newudpgw || log_error "Failed to download BadVPN."
chmod +x /usr/bin/badvpn-udpgw

# Create systemd service for BadVPN (multi-instance)
cat > /etc/systemd/system/badvpn-udpgw@.service <<EOF
[Unit]
Description=BadVPN UDP Gateway on port %i
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:%i --max-clients 500
Restart=always

[Install]
WantedBy=multi-user.target
EOF

log_info "Enabling and starting BadVPN services..."
for port in 7100 7200 7300 7400 7500 7600 7700 7800 7900; do
    systemctl enable --now badvpn-udpgw@${port}.service > /dev/null 2>&1 || log_warning "Failed to start badvpn-udpgw@${port}.service."
done

log_info "Configuring Stunnel..."
cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 222
connect = 127.0.0.1:22

[dropbear]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 700

[openvpn]
accept = 442
connect = 127.0.0.1:1194
EOF

openssl req -x509 -nodes -days 1095 -newkey rsa:2048 \
  -keyout /etc/stunnel/key.pem -out /etc/stunnel/cert.pem \
  -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=none/OU=none/CN=none/emailAddress=none" > /dev/null 2>&1 || log_error "Failed to generate stunnel certificate."

cat /etc/stunnel/{key.pem,cert.pem} > /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl enable stunnel4 > /dev/null 2>&1
systemctl restart stunnel4 > /dev/null 2>&1 || log_warning "Failed to restart stunnel4."

log_info "Configuring Fail2Ban..."
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5

[dropbear]
enabled = true
port    = 143,109
filter  = dropbear
logpath = /var/log/auth.log
maxretry = 5
EOF

systemctl enable fail2ban > /dev/null 2>&1
systemctl restart fail2ban > /dev/null 2>&1 || log_warning "Failed to restart fail2ban."

log_info "Applying firewall rules to block torrent traffic..."
iptables_rules=(
  "get_peers" "announce_peer" "find_node" "BitTorrent"
  "BitTorrent protocol" "peer_id=" ".torrent"
  "announce.php?passkey=" "torrent" "announce" "info_hash"
)
for s in "${iptables_rules[@]}"; do
  iptables -A FORWARD -m string --string "$s" --algo bm -j DROP
done
iptables-save > /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1 && netfilter-persistent reload > /dev/null 2>&1

log_info "Installing menu and SSH scripts..."
cd /usr/bin
menu_scripts=(
  auto-reboot.sh bw.sh clearcache.sh m-dns.sh m-domain.sh m-sshovpn.sh m-system.sh m-webmin.sh menu.sh restart.sh running.sh tcp.sh version
)
ssh_scripts=(
  add-host.sh autokill.sh cek.sh ceklim.sh certv2ray.sh delete.sh hapus.sh member.sh renew.sh speedtest_cli.py ssh-vpn.sh tendang.sh trial.sh user-lock.sh user-unlock.sh usernew.sh xp.sh
)
# Download menu scripts
for s in "${menu_scripts[@]}"; do
  base="${s%.sh}"
  wget -qO "$base" "https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/menu/$s" > /dev/null 2>&1 || log_warning "Failed to download $s."
  chmod +x "$base"
done
# Download ssh scripts
for s in "${ssh_scripts[@]}"; do
  if [[ "$s" == *.sh ]]; then
    base="${s%.sh}"
    wget -qO "$base" "https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/$s" > /dev/null 2>&1 || log_warning "Failed to download $s."
    chmod +x "$base"
  fi
done

log_info "Setting up cron jobs..."
cat > /etc/cron.d/re_otm <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
EOF

cat > /etc/cron.d/xp_otm <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
EOF

echo "7" > /home/re_otm
service cron restart > /dev/null 2>&1 && service cron reload > /dev/null 2>&1

log_info "Final cleanup..."
chown -R www-data:www-data /home/vps/public_html
rm -f /root/key.pem /root/cert.pem /root/ssh-vpn.sh /root/bbr.sh
history -c && echo "unset HISTFILE" >> /etc/profile
