#!/bin/bash

today=$(date +%s)
today_human=$(date +%d-%m-%Y)

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m              ⇱ AUTO DELETE ⇲               \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Checking and removing expired users..."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Parse /etc/shadow to get usernames and expiry
cut -d: -f1,8 /etc/shadow | grep -v ':\s*$' > /tmp/expirelist.txt

while IFS=: read -r username expiry_days; do
    [ -z "$expiry_days" ] && continue
    expiry_secs=$((expiry_days * 86400))
    expiry_date=$(date -d "@$expiry_secs" "+%d %b %Y")

    # Log all users with expiry
    echo "echo Expired- User: $username Expire at: $expiry_date" >> /usr/local/bin/alluser

    # Check expiry
    if [ "$expiry_secs" -lt "$today" ]; then
        echo "echo Expired- Username: $username expired on $expiry_date and removed on $today_human" >> /usr/local/bin/deleteduser
        echo "User $username expired on $expiry_date and removed on $today_human"
        userdel "$username"
    fi
done < /tmp/expirelist.txt

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn
