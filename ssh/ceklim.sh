#!/bin/bash

clear
echo "Checking VPS IP: $MYIP"
echo "---------------------------------------"
echo "        SSH Multi-Login Checker        "
echo "---------------------------------------"

if [ -e "/root/log-limit.txt" ]; then
    echo "Users exceeding maximum login limit:"
    echo "Time - Username - Number of Logins"
    echo "---------------------------------------"
    cat /root/log-limit.txt
else
    echo "No user has exceeded the login limit."
    echo "Or the user-limit script has not been run yet."
fi

echo "---------------------------------------"
read -n 1 -s -r -p "Press any key to return to menu"
m-sshovpn
