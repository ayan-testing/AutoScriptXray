#!/bin/bash

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m             ⇱ DELETE USER ⇲               \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

read -p "Username SSH to Delete: " user

if id "$user" &>/dev/null; then
    userdel "$user" &>/dev/null
    echo -e "User '$user' has been deleted."
else
    echo -e "Error: User '$user' does not exist."
fi

read -n 1 -s -r -p "Press any key to return to the menu..."
m-sshovpn
