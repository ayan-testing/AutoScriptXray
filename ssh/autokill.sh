#!/bin/bash

# Check if autokill is enabled
status="OFF"
[[ $(grep -c "^# Autokill" /etc/cron.d/tendang 2>/dev/null) -eq 1 ]] && status="ON"

clear
echo "----------------------------------------"
echo "            SSH AUTOKILL MENU           "
echo "----------------------------------------"
echo "Autokill Status: $status"
echo
echo "[1] Enable Autokill - Every 5 Minutes"
echo "[2] Enable Autokill - Every 10 Minutes"
echo "[3] Enable Autokill - Every 15 Minutes"
echo "[4] Disable Autokill"
echo

read -p "Select option [1-4]: " opt
[[ -z $opt ]] && exit

if [[ "$opt" =~ ^[1-3]$ ]]; then
  read -p "Max allowed SSH logins: " max
  [[ -z $max ]] && exit
fi

case $opt in
  1)
    interval=5
    ;;
  2)
    interval=10
    ;;
  3)
    interval=15
    ;;
  4)
    rm -f /etc/cron.d/tendang
    echo
    echo "Autokill disabled."
    systemctl reload cron >/dev/null 2>&1
    exit
    ;;
  *)
    echo "Invalid option."
    exit
    ;;
esac

# Create cron job
cat <<EOF >/etc/cron.d/tendang
# Autokill
*/$interval * * * * root /usr/bin/tendang $max
EOF

systemctl reload cron >/dev/null 2>&1

echo
echo "Autokill enabled."
echo "Max SSH logins allowed: $max"
echo "Interval: every $interval minutes"
