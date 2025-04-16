#!/bin/bash
clear
sleep 0.5
echo "╭──────────────────────────────────────────╮"
echo "│               DELETE MENU                │"
echo "╰──────────────────────────────────────────╯"
existing_users=""
count=1
for file in /etc/xray/trojan/*.json; do
    if [ -f "$file" ]; then
        nama_file=$(basename "$file" .json)
        existing_users+="│  $count. $nama_file\n"
        ((count++))
    fi
done
echo -e "╭──────────────────────────────────────────╮"
echo -e "│          Existing TROJAN Users           │"
echo -e "╰──────────────────────────────────────────╯"
echo -e "$existing_users" | column -t -s $'\n'
echo -e "╰──────────────────────────────────────────╯"
read -p $'\u27A4 Username : ' username
# check if configuration file exists
if [ ! -f "/etc/xray/trojan/$username.json" ]; then
    clear
    echo " [ ! ] Maaf konfigurasi vmess  $username tidak ditemukan."
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
    menu-trojan
    exit 1
fi
userid=$(cat /etc/xray/trojan/$username.json)
sed -i "/\"password\": \"$userid\"/,/{/d" /etc/xray/config.json
rm -f /etc/xray/trojan/$username.json
sleep 1
echo "[+] Trojan account has been deleted successfully"
service xray restart
sleep 0.5
read -n 1 -s -r -p "Press any key to continue..."
    menu-trojan