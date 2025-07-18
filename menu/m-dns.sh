#!/bin/bash

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Vars
dnsfile="/root/dns"

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}           DNS CHANGER${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show current DNS
if [[ -f "$dnsfile" ]]; then
  echo -e "\nActive DNS: $(cat $dnsfile)"
fi

# Menu
echo -e "\n [${CYAN}1${NC}] Change DNS"
echo -e " [${CYAN}2${NC}] Reset DNS to Default"
echo -e "\n [${CYAN}0${NC}] Back to Menu"
echo -ne "\nSelect option [0-2]: "; read dns

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

case $dns in
1)
  clear
  echo -ne "Enter DNS IP: "; read dns1
  [[ -z "$dns1" ]] && echo -e "\nNo DNS entered!" && sleep 1 && exec "$0"

  # Apply DNS
  echo "$dns1" > "$dnsfile"
  echo -e "nameserver $dns1" | tee /etc/resolv.conf /etc/resolvconf/resolv.conf.d/head >/dev/null
  systemctl restart resolvconf.service

  echo -e "\n${GREEN}DNS $dns1 applied successfully!${NC}"
  sleep 1
  exec "$0"
  ;;
2)
  clear
  read -p "Reset to Default DNS [Y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -f "$dnsfile"
    echo -e "${GREEN}Resetting to Google DNS...${NC}"
    echo -e "nameserver 8.8.8.8" | tee /etc/resolv.conf /etc/resolvconf/resolv.conf.d/head >/dev/null
    sleep 1
  else
    echo -e "${GREEN}Cancelled by user.${NC}"
    sleep 1
  fi
  exec "$0"
  ;;
0)
  clear
  m-system
  ;;
*)
  echo -e "${RED}Invalid option!${NC}"
  sleep 1
  exec "$0"
  ;;
esac
