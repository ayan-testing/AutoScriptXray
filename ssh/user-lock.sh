#!/bin/bash

read -p "Enter username to lock: " username

if id "$username" &>/dev/null; then
    passwd -l "$username"
    echo "-----------------------------------------------"
    echo "User '$username' has been locked successfully."
    echo "Login access for '$username' is now disabled."
    echo "-----------------------------------------------"
else
    echo "User '$username' not found."
    exit 1
fi
