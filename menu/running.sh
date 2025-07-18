#!/bin/bash

# Color Definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# VPS Info
MYIP=$(curl -s ifconfig.me)
REGION=$(curl -s ipinfo.io/region?token=ce3da57536810d)
CITY=$(curl -s ipinfo.io/city?token=ce3da57536810d)

# System Info
source /etc/os-release
total_ram=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
kernel_version=$(uname -r)
hostname=$HOSTNAME
domain=$(cat /etc/AutoScriptXray/domain 2>/dev/null || echo "Not set")

# Service Status Checks
check_status() {
  local status=$(systemctl is-active "$1" 2>/dev/null)
  [[ $status == "active" ]] && echo -e "${GREEN}Running${NC} (No Error)" || echo -e "${RED}Not Running${NC} (Error)"
}

status_ssh=$(check_status ssh)
status_dropbear=$(check_status dropbear)
status_stunnel=$(check_status stunnel4)
status_cron=$(check_status cron)
status_fail2ban=$(check_status fail2ban)
status_vnstat=$(check_status vnstat)
status_ws_tls=$(check_status ws-stunnel.service)
status_ws_drop=$(check_status ws-dropbear.service)

# Display Output
clear
echo -e "\e[1;33m------------------ SYSTEM INFORMATION ------------------\e[0m"
echo -e " Hostname   : $hostname"
echo -e " OS Name    : $NAME"
echo -e " Total RAM  : ${total_ram} MB"
echo -e " Kernel     : $kernel_version"
echo -e " Public IP  : $MYIP"
echo -e " Location   : $CITY, $REGION"
echo -e " Domain     : $domain"

echo -e "\n\e[1;33m--------------- SUBSCRIPTION INFORMATION ---------------\e[0m"
echo -e " Client Name : ayan-testing"
echo -e " Expiry      : Lifetime"
echo -e " Script Ver  : 1.0"

echo -e "\n\e[1;33m---------------- SERVICE INFORMATION -------------------\e[0m"
echo -e " SSH             : $status_ssh"
echo -e " Dropbear        : $status_dropbear"
echo -e " Stunnel4        : $status_stunnel"
echo -e " Cron            : $status_cron"
echo -e " Fail2Ban        : $status_fail2ban"
echo -e " VnStat          : $status_vnstat"
echo -e " WebSocket TLS   : $status_ws_tls"
echo -e " WebSocket NonTLS: $status_ws_drop"

echo -e "\n\e[1;33m--------------------------------------------------------\e[0m"
echo -e "            Script by @ayan-testing (Telegram)"
echo -e "\e[1;33m--------------------------------------------------------\e[0m"
echo ""

read -n 1 -s -r -p "Press any key to return to menu..."
menu
