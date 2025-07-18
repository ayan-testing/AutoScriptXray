#!/bin/bash

# Clear the screen
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

# Prompt for subdomain
read -rp "Enter subdomain to add: " host
echo ""

if [[ -z "$host" ]]; then
    echo "No subdomain entered."
else
    echo "$host" > /etc/AutoScriptXray/domain
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Domain has been set to: $host"
    echo "Remember to renew the certificate if required."
fi

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to the menu..."
m-domain
