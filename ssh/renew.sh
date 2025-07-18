#!/bin/bash

clear

# UI Header
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"

# Prompt for username
read -p "Username : " User

# Check if user exists
if id "$User" &>/dev/null; then
    read -p "Extend by (days): " Days

    # Calculate new expiration date
    Expire_Epoch=$(( $(date +%s) + Days * 86400 ))
    Expire_Date=$(date -u -d "@$Expire_Epoch" +%Y-%m-%d)
    Expire_Display=$(date -u -d "@$Expire_Epoch" '+%d %b %Y')

    # Renew user account
    passwd -u "$User"
    usermod -e "$Expire_Date" "$User"

    # Display result
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
    echo -e " Username   : $User"
    echo -e " Days Added : $Days"
    echo -e " Expires on : $Expire_Display"
else
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
    echo -e "   ⚠️  User '$User' does not exist."
fi

# Footer
echo -e "\n\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn
