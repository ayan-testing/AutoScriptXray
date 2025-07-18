#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com)
clear
echo "============== RESTART MENU =============="
echo "1. Restart All Services"
echo "2. Restart OpenSSH"
echo "3. Restart Dropbear"
echo "4. Restart Stunnel4"
echo "5. Restart OpenVPN"
echo "6. Restart Squid"
echo "7. Restart Nginx"
echo "8. Restart Badvpn"
echo "9. Restart WebSocket"
echo ""
echo "0. Back to Menu"
echo "x. Exit"
echo "=========================================="
read -p "Select menu: " choice
clear

restart_message() {
  echo ""
  echo "Restarting $1..."
  sleep 1
}

pause_return() {
  echo ""
  read -n 1 -s -r -p "Press any key to return to the menu"
  restart
}

case $choice in
  1)
    restart_message "All Services"
    /etc/init.d/ssh restart
    /etc/init.d/dropbear restart
    /etc/init.d/stunnel4 restart
    /etc/init.d/openvpn restart
    /etc/init.d/fail2ban restart
    /etc/init.d/cron restart
    /etc/init.d/nginx restart
    /etc/init.d/squid restart
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
    systemctl restart sshws.service
    systemctl restart ws-dropbear.service
    systemctl restart ws-stunnel.service
    systemctl restart trojan-go.service
    echo "All services restarted."
    pause_return
    ;;
  2) restart_message "OpenSSH"; /etc/init.d/ssh restart; pause_return ;;
  3) restart_message "Dropbear"; /etc/init.d/dropbear restart; pause_return ;;
  4) restart_message "Stunnel4"; /etc/init.d/stunnel4 restart; pause_return ;;
  5) restart_message "OpenVPN"; /etc/init.d/openvpn restart; pause_return ;;
  6) restart_message "Squid"; /etc/init.d/squid restart; pause_return ;;
  7) restart_message "Nginx"; /etc/init.d/nginx restart; pause_return ;;
  8) 
    restart_message "Badvpn"
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
    echo "Badvpn restarted."
    pause_return
    ;;
  9) 
    restart_message "WebSocket Services"
    systemctl restart sshws.service
    systemctl restart ws-dropbear.service
    systemctl restart ws-stunnel.service
    echo "WebSocket services restarted."
    pause_return
    ;;
  0) m-system; exit ;;
  x) exit ;;
  *) echo "Invalid selection"; sleep 1; restart ;;
esac
