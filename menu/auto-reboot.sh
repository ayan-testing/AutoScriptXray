#!/bin/bash

REBOOT_SCRIPT="/usr/local/bin/reboot_otomatis"
CRON_FILE="/etc/cron.d/reboot_otomatis"
LOG_FILE="/root/log-reboot.txt"

# Create reboot script if it doesn't exist
if [[ ! -f $REBOOT_SCRIPT ]]; then
cat <<EOF > "$REBOOT_SCRIPT"
#!/bin/bash
echo "Server successfully rebooted on \$(date '+%m-%d-%Y %T')" >> "$LOG_FILE"
/sbin/shutdown -r now
EOF
chmod +x "$REBOOT_SCRIPT"
fi

# Display menu
clear
echo -e "==================== AUTO-REBOOT MENU ===================="
echo -e " 1) Every 1 Hour"
echo -e " 2) Every 6 Hours"
echo -e " 3) Every 12 Hours"
echo -e " 4) Every 1 Day"
echo -e " 5) Every 1 Week"
echo -e " 6) Every 1 Month"
echo -e " 7) Disable Auto-Reboot"
echo -e " 8) View Reboot Log"
echo -e " 9) Clear Reboot Log"
echo -e " 0) Back to Menu"
echo -e "=========================================================="
read -rp "Select option: " choice

set_cron() {
    echo "$1 root $REBOOT_SCRIPT" > "$CRON_FILE"
    echo "Auto-Reboot set: $2"
}

case $choice in
  1) set_cron "10 * * * *" "Every 1 Hour" ;;
  2) set_cron "10 */6 * * *" "Every 6 Hours" ;;
  3) set_cron "10 */12 * * *" "Every 12 Hours" ;;
  4) set_cron "10 0 * * *" "Every 1 Day" ;;
  5) set_cron "10 0 */7 * *" "Every 1 Week" ;;
  6) set_cron "10 0 1 * *" "Every 1 Month" ;;
  7) rm -f "$CRON_FILE"; echo "Auto-Reboot has been disabled." ;;
  8)
    clear
    echo "================== AUTO-REBOOT LOG =================="
    if [[ -f $LOG_FILE && -s $LOG_FILE ]]; then
        cat "$LOG_FILE"
    else
        echo "No reboot activity found."
    fi
    echo "====================================================="
    read -n 1 -s -r -p "Press any key to return..."
    ;;
  9)
    > "$LOG_FILE"
    echo "Reboot log has been cleared."
    read -n 1 -s -r -p "Press any key to return..."
    ;;
  0) m-system ;;
  *) echo "Invalid selection."; sleep 1 ;;
esac
