#!/bin/bash

# File containing port info
PORT_INFO="/etc/AutoScriptXray/ports.json"

# Get public IP and domain
MYIP=$(wget -qO- ipv4.icanhazip.com)
DOMAIN=$(cat /etc/AutoScriptXray/domain)
IP=$(curl -sS ifconfig.me)

# Function to fetch ports from JSON
get_port() {
    jq -r ".$1" "$PORT_INFO"
}

# Read ports from JSON
portsshws=$(get_port "sshws")
wsssl=$(get_port "wsssl")
opensh=$(get_port "openssh")
db=$(get_port "dropbear")
ssl=$(get_port "stunnel")
squid=$(get_port "squid")
ohpssh=$(get_port "ohpssh")
ohpdb=$(get_port "ohpdb")
ohpovpn=$(get_port "ohpovpn")

# Get OpenVPN ports dynamically
ovpn_tcp=$(netstat -nlpt | grep -i openvpn | awk -F: '/0.0.0.0/ {print $NF}')
ovpn_udp=$(netstat -nlpu | grep -i openvpn | awk -F: '/0.0.0.0/ {print $NF}')

# Create trial account
LOGIN="trial$(tr -dc X-Z0-9 </dev/urandom | head -c4)"
PASS="1"
DAYS_ACTIVE=1

# Add user
useradd -e $(date -d "$DAYS_ACTIVE days" +"%Y-%m-%d") -s /bin/false -M "$LOGIN"
echo -e "$PASS\n$PASS" | passwd "$LOGIN" &>/dev/null
EXP_DATE=$(chage -l "$LOGIN" | grep "Account expires" | cut -d: -f2)

# Display account info
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m            TRIAL SSH              \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username   : $LOGIN"
echo -e "Password   : $PASS"
echo -e "Expired On : $EXP_DATE"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "IP         : $IP"
echo -e "Host       : $DOMAIN"
echo -e "OpenSSH    : $opensh"
echo -e "Dropbear   : $db"
echo -e "SSH WS     : $portsshws"
echo -e "SSH SSL WS : $wsssl"
echo -e "SSL/TLS    : $ssl"
echo -e "UDPGW      : 7100-7900"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Payload WSS:"
echo -e "GET wss://bug-host HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Payload WS:"
echo -e "GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Wait for key press
read -n 1 -s -r -p "Press any key to return to menu"
m-sshovpn
