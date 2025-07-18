#!/bin/bash

clear
echo -e "\033[33m=========== SYSTEM MENU ===========\033[0m"
echo ""
echo " [1] Domain Panel"
echo " [2] VPS Speedtest"
echo " [3] Set Auto Reboot"
echo " [4] Restart All Services"
echo " [5] Check Bandwidth"
echo " [6] Install TCP BBR"
echo " [7] DNS Changer"
echo ""
echo " [0] Back to Main Menu"
echo " [x] Exit"
echo ""
echo -e "\033[33m===================================\033[0m"
echo ""

read -p "Select option: " opt
echo ""

case $opt in
  1) clear; m-domain; exit ;;
  2) clear; speedtest; exit ;;
  3) clear; auto-reboot; exit ;;
  4) clear; restart; exit ;;
  5) clear; bw; exit ;;
  6) clear; m-tcp; exit ;;
  7) clear; m-dns; exit ;;
  0) clear; menu; exit ;;
  x) exit ;;
  *) echo "Invalid option"; sleep 1; m-system ;;
esac
