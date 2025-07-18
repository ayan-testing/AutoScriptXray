#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

# Check if running on OpenVZ (unsupported)
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported. Use KVM or VMWare virtualization."
    exit 1
fi

# Prepare system
localip=$(hostname -I | cut -d ' ' -f1)
hostname=$(hostname)
domain_from_etc=$(grep -w "$hostname" /etc/hosts | awk '{print $2}')
[ "$hostname" != "$domain_from_etc" ] && echo "$localip $hostname" >> /etc/hosts

# Check if kernel headers are installed
kernel_version=$(uname -r)
required_pkg="linux-headers-$kernel_version"
if ! dpkg-query -W --showformat='${Status}\n' "$required_pkg" | grep -q "install ok installed"; then
    echo "Installing required kernel headers..."
    apt-get --yes install "$required_pkg"
    echo ""
    echo "Please run: apt update && apt upgrade -y && reboot"
    echo "Then re-run this script."
    read -p "Press Enter to exit..."
    exit 1
fi

# Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Install required packages
apt install -y git curl python >/dev/null 2>&1

mkdir -p /etc/AutoScriptXray

# Ask for domain
clear
echo "---------------------------"
echo "      VPS DOMAIN SETUP     "
echo "---------------------------"
read -rp "Enter Your Domain: " user_domain

echo "$user_domain" > /etc/AutoScriptXray/domain

# Install SSH WebSocket
echo "Installing SSH WebSocket..."
wget -q https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
wget -q https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh

# Log installation info
echo "Service & Port:" | tee -a /root/log-install.txt
echo "OpenSSH                  : 22" | tee -a /root/log-install.txt
echo "SSH WebSocket            : 80" | tee -a /root/log-install.txt
echo "SSH SSL WebSocket        : 443" | tee -a /root/log-install.txt
echo "Stunnel4                 : 222, 777" | tee -a /root/log-install.txt
echo "Dropbear                 : 109, 143" | tee -a /root/log-install.txt
echo "Badvpn                   : 7100-7900" | tee -a /root/log-install.txt
echo "Nginx                    : 81" | tee -a /root/log-install.txt

# Cleanup and reboot
rm -f /root/setup.sh /root/insshws.sh
echo ""
echo "Rebooting in 10 seconds..."
sleep 10
reboot
