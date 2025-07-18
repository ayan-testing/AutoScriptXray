#!/bin/bash

cek=$(netstat -ntlp | grep 10000 | awk '{print $7}' | cut -d'/' -f2)

install_webmin() {
    clear
    echo "Installing Webmin..."
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
    apt install -y gnupg gnupg1 gnupg2 >/dev/null
    wget -q http://www.webmin.com/jcameron-key.asc
    apt-key add jcameron-key.asc >/dev/null
    apt update >/dev/null
    apt install -y webmin >/dev/null
    sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
    /etc/init.d/webmin restart >/dev/null
    rm -f jcameron-key.asc
    echo "Webmin installed at http://$MYIP:10000"
    read -n 1 -s -r -p "Press any key to return..."
    m-webmin
}

restart_webmin() {
    clear
    echo "Restarting Webmin..."
    service webmin restart >/dev/null
    echo "Webmin restarted."
    read -n 1 -s -r -p "Press any key to return..."
    m-webmin
}

uninstall_webmin() {
    clear
    echo "Uninstalling Webmin..."
    rm -f /etc/apt/sources.list.d/webmin.list
    apt update >/dev/null
    apt autoremove --purge -y webmin >/dev/null
    echo "Webmin uninstalled."
    read -n 1 -s -r -p "Press any key to return..."
    m-webmin
}

# Display status
status="[Not Installed]"
[[ "$cek" == "perl" ]] && status="[Installed]"

clear
echo "========= WEBMIN MENU ========="
echo " Status: $status"
echo " [1] Install Webmin"
echo " [2] Restart Webmin"
echo " [3] Uninstall Webmin"
echo " [0] Back to Menu"
echo " [x] Exit"
echo "==============================="

read -p "Select an option: " num
case $num in
    1) install_webmin ;;
    2) restart_webmin ;;
    3) uninstall_webmin ;;
    0) menu ;;
    x) exit ;;
    *) echo "Invalid input"; sleep 1; m-webmin ;;
esac
