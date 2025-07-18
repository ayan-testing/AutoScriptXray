#!/bin/bash

# === Basic Setup ===
export DEBIAN_FRONTEND=noninteractive
domain=$(cat /etc/AutoScriptXray/domain)
MYIP=$(wget -qO- ipv4.icanhazip.com)

# Update & Cleanup
apt update -y && apt dist-upgrade -y && apt upgrade -y
apt-get purge -y ufw firewalld exim4 samba* apache2* bind9* sendmail* unscd || true
apt autoremove -y && apt autoclean -y

# Install Essentials
apt install -y \
  netfilter-persistent screen curl jq bzip2 gzip vnstat coreutils rsyslog \
  iftop zip unzip git apt-transport-https build-essential figlet \
  python make net-tools nano sed gnupg gnupg1 bc dirmngr \
  lsof libz-dev gcc g++ \
  zlib1g-dev libssl-dev libssl1.0-dev dos2unix fail2ban \
  shc wget stunnel4 nginx socat xz-utils

gem install lolcat

# Timezone & Locale
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# Disable IPv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo "echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6" >> /etc/rc.local

# === rc.local Setup ===
cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/rc.local <<EOF
#!/bin/sh -e
exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local && systemctl start rc-local

# === SSH Configuration ===
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
for port in 22 200 500 666 51443 40000 58080; do
    sed -i "/Port 22/a Port $port" /etc/ssh/sshd_config
done
/etc/init.d/ssh restart

# === Dropbear Configuration ===
apt install -y dropbear
sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/' /etc/default/dropbear
sed -i 's|DROPBEAR_EXTRA_ARGS=.*|DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"|' /etc/default/dropbear
echo -e "/bin/false\n/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# === Nginx Setup ===
rm -f /etc/nginx/{sites-available/default,sites-enabled/default,conf.d/default.conf}
mkdir -p /home/vps/public_html
mkdir -p /etc/systemd/system/nginx.service.d

# Download Nginx configs and web files
files=(
  "nginx.conf:/etc/nginx/nginx.conf"
  "vps.conf:/etc/nginx/conf.d/vps.conf"
  "xray.conf:/etc/nginx/conf.d/xray.conf"
  "index:/home/vps/public_html/index.html"
  ".htaccess:/home/vps/public_html/.htaccess"
)
for f in "${files[@]}"; do
    name="${f%%:*}"
    path="${f##*:}"
    wget -qO "$path" "https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/$name"
done

cat > /etc/systemd/system/nginx.service.d/override.conf <<EOF
[Service]
ExecStartPost=/bin/sleep 0.1
EOF

systemctl daemon-reload
systemctl restart nginx

# === SSL Certificate Setup with acme.sh ===
mkdir -p /root/.acme.sh
curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "$domain" \
  --fullchainpath /etc/AutoScriptXray/cert.crt \
  --keypath /etc/AutoScriptXray/cert.key --ecc

# === BadVPN Setup ===
wget -qO /usr/bin/badvpn-udpgw https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/newudpgw
chmod +x /usr/bin/badvpn-udpgw
for port in {7100..7900..100}; do
    echo "screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500" >> /etc/rc.local
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500
done

# === Stunnel Setup ===
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
  -subj "/C=ID/ST=Indonesia/L=Jakarta/O=none/OU=none/CN=none/emailAddress=none"

cat /etc/stunnel/{key.pem,cert.pem} > /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl enable stunnel4
systemctl restart stunnel4

# === DDoS Protection ===
mkdir -p /usr/local/ddos
urls=(
  "ddos.conf"
  "LICENSE"
  "ignore.ip.list"
  "ddos.sh"
)
for file in "${urls[@]}"; do
  wget -q -O /usr/local/ddos/$file http://www.inetbase.com/scripts/ddos/$file
done
chmod 0755 /usr/local/ddos/ddos.sh
ln -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1

# === Firewall Torrent Blocking ===
iptables_rules=(
  "get_peers" "announce_peer" "find_node" "BitTorrent"
  "BitTorrent protocol" "peer_id=" ".torrent"
  "announce.php?passkey=" "torrent" "announce" "info_hash"
)
for s in "${iptables_rules[@]}"; do
  iptables -A FORWARD -m string --string "$s" --algo bm -j DROP
done
iptables-save > /etc/iptables.up.rules
netfilter-persistent save && netfilter-persistent reload

# === Script Menu Installer ===
cd /usr/bin
scripts=(
  menu running clearcache m-sshovpn usernew trial
  renew hapus cek member delete autokill ceklim
  tendang sshws user-lock user-unlock m-system
  m-domain add-host certv2ray speedtest m-tcp
  auto-reboot restart bw xp m-dns
)
for s in "${scripts[@]}"; do
  wget -qO "$s" "https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/menu/$s.sh"
  chmod +x "$s"
done

# === Cron Jobs ===
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
service cron restart && service cron reload

# === Final Cleanup ===
chown -R www-data:www-data /home/vps/public_html
rm -f /root/key.pem /root/cert.pem /root/ssh-vpn.sh /root/bbr.sh
history -c && echo "unset HISTFILE" >> /etc/profile
