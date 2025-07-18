#!/bin/bash

MYIP=$(curl -sS ifconfig.me)
clear
echo "Checking VPS..."

# VPS Information
domain=$(cat /etc/AutoScriptXray/domain)

# Certificate Status
cert_file="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
modifyTime=$(stat "$cert_file" | grep Modify | cut -d ' ' -f 2,3)
modifyTime1=$(date +%s -d "$modifyTime")
currentTime=$(date +%s)
days=$(( (currentTime - modifyTime1) / 86400 ))
remainingDays=$(( 90 - days ))
tlsStatus=$remainingDays
[[ $remainingDays -le 0 ]] && tlsStatus="expired"

# System Info
uptime=$(uptime -p | cut -d " " -f 2-10)
IPVPS=$(curl -s ifconfig.me)
LOC=$(curl -s ifconfig.co/country)
DATE2=$(date -R | cut -d " " -f -5)

# RAM Info
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')

# Static Info
Name="ayan-testing"
Exp2="Lifetime"

# Menu
echo "-------------------------------------------------"
echo "                    VPS INFO                    "
echo "-------------------------------------------------"
echo " OS            : $(hostnamectl | grep 'Operating System' | cut -d ' ' -f5-)"
echo " Uptime        : $uptime"
echo " Public IP     : $IPVPS"
echo " Country       : $LOC"
echo " Domain        : $domain"
echo " Date & Time   : $DATE2"
echo "-------------------------------------------------"
echo "                    RAM INFO                    "
echo "-------------------------------------------------"
echo " RAM Used      : $uram MB"
echo " RAM Total     : $tram MB"
echo "-------------------------------------------------"
echo "                     MENU                       "
echo "-------------------------------------------------"
echo " 1 : Menu SSH"
echo " 2 : Menu Setting"
echo " 3 : Status Service"
echo " 4 : Clear RAM Cache"
echo " 5 : Reboot VPS"
echo " x : Exit Script"
echo "-------------------------------------------------"
echo " Client Name   : $Name"
echo " Expired       : $Exp2"
echo "-------------------------------------------------"
echo ""

read -p "Select menu: " opt
echo ""

case $opt in
  1) clear; m-sshovpn ;;
  2) clear; m-system ;;
  3) clear; running ;;
  4) clear; clearcache ;;
  5) clear; /sbin/reboot ;;
  x) exit ;;
  *) echo "Invalid option"; sleep 1; menu ;;
esac
