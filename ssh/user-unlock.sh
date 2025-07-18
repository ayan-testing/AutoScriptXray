#!/bin/bash

read -p "Enter username to unlock: " username

if id "$username" &>/dev/null; then
    passwd -u "$username"
    echo "-------------------------------------------"
    echo "User '$username' has been unlocked successfully."
    echo "Login access for '$username' has been restored."
    echo "-------------------------------------------"
else
    echo "User '$username' not found."
    exit 1
fi
