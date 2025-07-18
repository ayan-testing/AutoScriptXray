#!/bin/bash

clear

echo -e "[ \033[32mInfo\033[0m ] Clearing RAM cache..."
echo 1 > /proc/sys/vm/drop_caches
sleep 1
echo -e "[ \033[32mOK\033[0m ] Cache cleared."
sleep 2
menu
