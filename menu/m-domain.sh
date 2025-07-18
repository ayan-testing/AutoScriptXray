#!/bin/bash

clear

# Display menu
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m        • DOMAIN MENU •            \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " [\e[36m1\e[0m] Change VPS Domain"
echo -e " [\e[36m2\e[0m] Renew Domain Certificate"
echo -e " [\e[31m0\e[0m] Back to Menu"
echo -e " [x] Exit"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Select menu: " opt

# Handle input
case "$opt" in
  1) clear; add-host ;;
  2) clear; certv2ray ;;
  0) clear; m-system ;;
  x|X) exit ;;
  *) echo "Invalid selection"; sleep 1; m-domain ;;
esac
