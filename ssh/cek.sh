#!/bin/bash

clear
echo ""

# Determine auth log file
if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log"
elif [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure"
else
    echo "Auth log not found."
    exit 1
fi

# Show Dropbear logins
echo "Dropbear User Login"
echo "PID  |  Username  |  IP Address"
ps aux | grep -i dropbear | awk '{print $2}' | while read PID; do
    grep "dropbear\[$PID\].*Password auth succeeded" "$LOG" > /tmp/db-login.txt
    if [ -s /tmp/db-login.txt ]; then
        USER=$(awk '{print $10}' /tmp/db-login.txt)
        IP=$(awk '{print $12}' /tmp/db-login.txt)
        echo "$PID - $USER - $IP"
    fi
done
echo ""

# Show OpenSSH logins
echo "OpenSSH User Login"
echo "PID  |  Username  |  IP Address"
ps aux | grep "\[priv\]" | awk '{print $2}' | while read PID; do
    grep "sshd\[$PID\].*Accepted password for" "$LOG" > /tmp/ssh-login.txt
    if [ -s /tmp/ssh-login.txt ]; then
        USER=$(awk '{print $9}' /tmp/ssh-login.txt)
        IP=$(awk '{print $11}' /tmp/ssh-login.txt)
        echo "$PID - $USER - $IP"
    fi
done
echo ""

# Show OpenVPN TCP logins
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo "OpenVPN TCP User Login"
    echo "Username  |  IP Address  |  Connected Since"
    grep "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d ',' -f 2,3,8 | sed 's/,/      /g'
    echo ""
fi

# Show OpenVPN UDP logins
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo "OpenVPN UDP User Login"
    echo "Username  |  IP Address  |  Connected Since"
    grep "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d ',' -f 2,3,8 | sed 's/,/      /g'
    echo ""
fi

# Clean up
rm -f /tmp/db-login.txt /tmp/ssh-login.txt

# Wait for key
read -n 1 -s -r -p "Press any key to return to menu"
m-sshovpn
