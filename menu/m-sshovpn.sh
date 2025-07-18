#!/bin/bash

clear
echo "=== SSH MENU ==="
echo ""
echo " [1] Create SSH & WS Account"
echo " [2] Trial SSH & WS Account"
echo " [3] Renew SSH & WS Account"
echo " [4] Delete SSH & WS Account"
echo " [5] Check SSH & WS Login"
echo " [6] List SSH & WS Users"
echo " [7] Delete Expired SSH & WS Users"
echo " [8] Set SSH Autokill"
echo " [9] Check Multi Login Users"
echo " [10] View Created Accounts"
echo " [11] Edit SSH Login Banner"
echo " [12] Lock SSH User"
echo " [13] Unlock SSH User"
echo ""
echo " [0] Back to Main Menu"
echo " [x] Exit"
echo ""

read -p "Select option: " opt
echo ""

case $opt in
  1) clear; usernew ;;
  2) clear; trial ;;
  3) clear; renew ;;
  4) clear; hapus ;;
  5) clear; cek ;;
  6) clear; member ;;
  7) clear; delete ;;
  8) clear; autokill ;;
  9) clear; ceklim ;;
 10) clear; cat /etc/log-create-ssh.log ;;
 11) clear; nano /etc/issue.net ;;
 12) clear; user-lock ;;
 13) clear; user-unlock ;;
  0) clear; menu ;;
  x) exit ;;
  *) echo "Invalid option"; sleep 1; m-sshovpn ;;
esac
