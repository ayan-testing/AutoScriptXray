#!/bin/bash

NC='\e[0m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'

show_menu() {
  clear
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo -e "${BLUE}                BANDWIDTH MONITOR                ${NC}"
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo -e ""
  echo -e " 1) View Total Bandwidth"
  echo -e " 2) Usage Every 5 Minutes"
  echo -e " 3) Usage Per Hour"
  echo -e " 4) Usage Per Day"
  echo -e " 5) Usage Per Month"
  echo -e " 6) Usage Per Year"
  echo -e " 7) Highest Usage Table"
  echo -e " 8) Hourly Statistics"
  echo -e " 9) Live Usage (Monitor)"
  echo -e "10) Live Traffic (Every 5s)"
  echo -e ""
  echo -e " 0) Back to Menu"
  echo -e " x) Exit"
  echo -e ""
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo ""
}

run_vnstat() {
  local flag=$1
  local title=$2
  clear
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo -e "${BLUE}            $title            ${NC}"
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo ""
  vnstat $flag
  echo ""
  echo -e "${YELLOW}-------------------------------------------------${NC}"
  echo ""
  read -n 1 -s -r -p "Press any key to return..."
  bw
}

# Menu selection
show_menu
read -rp "Select menu: " opt
echo ""

case $opt in
  1)  run_vnstat ""            "TOTAL BANDWIDTH USAGE" ;;
  2)  run_vnstat "-5"          "USAGE EVERY 5 MINUTES" ;;
  3)  run_vnstat "-h"          "USAGE PER HOUR" ;;
  4)  run_vnstat "-d"          "USAGE PER DAY" ;;
  5)  run_vnstat "-m"          "USAGE PER MONTH" ;;
  6)  run_vnstat "-y"          "USAGE PER YEAR" ;;
  7)  run_vnstat "-t"          "HIGHEST USAGE TABLE" ;;
  8)  run_vnstat "-hg"         "HOURLY STATISTICS" ;;
  9)  run_vnstat "-l"          "LIVE BANDWIDTH USAGE (Press Ctrl+C to Exit)" ;;
  10) run_vnstat "-tr"         "LIVE TRAFFIC (5s Interval)" ;;
  0)  m-system ;;
  x)  exit ;;
  *)  echo -e "\nInvalid option. Returning..."; sleep 1; bw ;;
esac
