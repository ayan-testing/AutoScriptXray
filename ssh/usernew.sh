#!/bin/bash

# Constants
DOMAIN_FILE="/etc/AutoScriptXray/domain"
PORT_INFO="/etc/port-info.json"
LOG_FILE="/etc/log-create-ssh.log"

# Functions
get_port() {
    jq -r ".$1" "$PORT_INFO"
}

# Setup
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m            SSH Account            \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Read inputs
read -p "Username         : " Login
read -p "Password         : " Pass
read -p "Expired (days)   : " masaaktif

# System info
IP=$(curl -s ifconfig.me)
DOMAIN=$(cat "$DOMAIN_FILE")
EXP_DATE=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Create user
useradd -e "$EXP_DATE" -s /bin/false -M "$Login"
echo -e "$Pass\n$Pass" | passwd "$Login" &>/dev/null
exp=$(chage -l "$Login" | grep "Account expires" | cut -d: -f2 | xargs)

# Log output
{
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "\E[0;41;36m            SSH Account            \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Username    : $Login"
  echo -e "Password    : $Pass"
  echo -e "Expired On  : $exp"
  echo -e "IP          : $IP"
  echo -e "Host        : $DOMAIN"
  echo -e "OpenSSH     : $(get_port openssh)"
  echo -e "SSH WS      : $(get_port ssh_ws)"
  echo -e "SSH SSL WS  : $(get_port ssh_ssl_ws)"
  echo -e "SSL/TLS     : $(get_port stunnel)"
  echo -e "UDPGW       : 7100-7900"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Payload WSS"
  echo -e "GET wss://example.com HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Payload WS"
  echo -e "GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
} | tee -a "$LOG_FILE"

echo ""
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn
