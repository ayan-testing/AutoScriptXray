#!/bin/bash

systemctl stop nginx

# Extract domain from config
domain=$(cat /etc/AutoScriptXray/domain | cut -d'=' -f2)

# Check if any process is using port 80
process_on_80=$(lsof -i:80 | awk 'NR==2 {print $1}')

if [[ -n "$process_on_80" ]]; then
    echo "Port 80 is in use by: $process_on_80"
    echo "Stopping $process_on_80..."
    systemctl stop "$process_on_80"
    sleep 2
fi

echo "Renewing SSL certificate for domain: $domain"
sleep 1

/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d "$domain" \
    --fullchainpath /etc/AutoScriptXray/cert.crt \
    --keypath /etc/AutoScriptXray/cert.key --ecc

echo "SSL certificate renewed."

# Save domain
echo "$domain" > /etc/AutoScriptXray/domain

# Restart services
if [[ -n "$process_on_80" ]]; then
    echo "Restarting $process_on_80..."
    systemctl restart "$process_on_80"
fi

systemctl restart nginx
echo "All services restarted."

read -n 1 -s -r -p "Press any key to return to menu"
m-domain
