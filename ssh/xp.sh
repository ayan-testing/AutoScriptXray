#!/bin/bash

clear

today=$(date +%s)

while IFS=: read -r user _ _ _ _ _ _ exp _; do
    [[ -z $exp || $exp -eq 0 ]] && continue
    expire_time=$((exp * 86400))
    if (( expire_time < today )); then
        userdel --force "$user"
    fi
done < /etc/shadow
