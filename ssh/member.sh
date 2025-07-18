#!/bin/bash

clear

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m                 MEMBER SSH               \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "USERNAME          EXP DATE          STATUS"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

while IFS=: read -r username _ uid _ _ _ _; do
  if [[ $uid -ge 1000 && $username != "nobody" ]]; then
    exp=$(chage -l "$username" | awk -F": " '/Account expires/ {print $2}')
    status=$(passwd -S "$username" | awk '{print $2}')
    if [[ $status == "L" ]]; then
      printf "%-17s %-17s LOCKED\n" "$username" "$exp"
    else
      printf "%-17s %-17s UNLOCKED\n" "$username" "$exp"
    fi
  fi
done < /etc/passwd

count=$(awk -F: '$3 >= 1000 && $1 != "nobody"' /etc/passwd | wc -l)

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Account number: $count user"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to menu"

m-sshovpn
