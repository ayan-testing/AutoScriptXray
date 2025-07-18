#!/bin/bash

MYIP=$(wget -qO- ipv4.icanhazip.com)
MAX=${1:-1}  # Default max sessions per user is 1, or custom if passed as argument
clear
echo "Checking VPS"

# Detect OS log path
if [[ -f /var/log/auth.log ]]; then
    LOG="/var/log/auth.log"
    SSH_SERVICE="ssh"
elif [[ -f /var/log/secure ]]; then
    LOG="/var/log/secure"
    SSH_SERVICE="sshd"
else
    echo "Log file not found."
    exit 1
fi

# Restart services
systemctl restart $SSH_SERVICE >/dev/null 2>&1
systemctl restart dropbear >/dev/null 2>&1

# Get list of users with /home directory
users=($(awk -F: '/\/home\// {print $1}' /etc/passwd))
declare -A user_count
declare -A user_pids

# Analyze Dropbear logins
grep -i "dropbear.*Password auth succeeded" $LOG > /tmp/logins.txt
for pid in $(pgrep dropbear); do
    grep "dropbear\[$pid\]" /tmp/logins.txt | while read -r line; do
        user=$(echo "$line" | awk '{print $10}')
        user_count["$user"]=$(( ${user_count["$user"]} + 1 ))
        user_pids["$user"]+="$pid "
    done
done

# Analyze OpenSSH logins
grep "sshd.*Accepted password for" $LOG >> /tmp/logins.txt
for pid in $(ps aux | grep '\[priv\]' | awk '{print $2}'); do
    grep "sshd\[$pid\]" /tmp/logins.txt | while read -r line; do
        user=$(echo "$line" | awk '{print $9}')
        user_count["$user"]=$(( ${user_count["$user"]} + 1 ))
        user_pids["$user"]+="$pid "
    done
done

# Kill users exceeding the session limit
for user in "${users[@]}"; do
    count=${user_count["$user"]:-0}
    if (( count > MAX )); then
        echo "$(date '+%Y-%m-%d %X') - $user - $count"
        echo "$(date '+%Y-%m-%d %X') - $user - $count" >> /root/log-limit.txt
        for pid in ${user_pids["$user"]}; do
            kill "$pid" 2>/dev/null
        done
    fi
done
