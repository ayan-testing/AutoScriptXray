#!/bin/bash

# Color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Logging functions
log_info() {echo -e "${GREEN}[ Info ]${NC} $1"}
log_error() {echo -e "${RED}[ Error ]${NC} $1" >&2}
log_warning() {echo -e "${YELLOW}[ Warning ]${NC} $1"}

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "You need to run this script as root"
    exit 1
fi

# Check if running on OpenVZ (unsupported)
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    log_error "OpenVZ is not supported. Use KVM or VMWare virtualization."
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
    log_info "Installing required kernel headers..."
    if ! apt-get --yes install "$required_pkg"; then
        log_error "Failed to install $required_pkg."
        log_warning "Please run: apt update && apt upgrade -y && reboot"
        log_warning "Then re-run this script."
        read -p "Press Enter to exit..."
        exit 1
    fi
    log_info "Kernel headers installed. Please reboot and re-run the script."
    exit 0
fi

# Install required packages
apt install -y git curl python >/dev/null 2>&1

mkdir -p /etc/AutoScriptXray

# Ask for domain
clear
echo "---------------------------"
echo "      VPS DOMAIN SETUP     "
echo "---------------------------"
read -rp "Enter Your Domain: " user_domain

if echo "$user_domain" > /etc/AutoScriptXray/domain; then
    log_info "Domain saved to /etc/AutoScriptXray/domain."
else
    log_error "Failed to save domain."
    exit 1
fi

# Install SSH WebSocket
echo "Installing SSH WebSocket..."
wget -q https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
wget -q https://raw.githubusercontent.com/ayan-testing/AutoScriptXray/master/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh

# Log installation info
echo "Service & Port:"
echo "OpenSSH                  : 22"
echo "SSH WebSocket            : 80"
echo "SSH SSL WebSocket        : 443"
echo "Stunnel4                 : 222, 777"
echo "Dropbear                 : 109, 143"
echo "Badvpn                   : 7100-7900"
echo "Nginx                    : 81"

# Cleanup and reboot
rm -f /root/setup.sh /root/insshws.sh
log_info "Cleanup done. Rebooting in 10 seconds..."
sleep 10
reboot
