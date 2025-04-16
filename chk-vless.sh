#!/bin/bash
clear
sleep 0.5
echo "╭──────────────────────────────────────────╮"
echo "│            List vless account            │"
echo "╰──────────────────────────────────────────╯"
existing_users=""
count=1
for file in /etc/xray/vless/*.json; do
    if [ -f "$file" ]; then
        nama_file=$(basename "$file" .json)
        uuid=$(cat $file)
        exp=$(sed -nE "/\"id\": \"$uuid\"/{n;s/\s*\"exp\": \"([^\"]+)\".*/\1/p}" "/etc/xray/config.json")
        existing_users+="│  $count. $nama_file >> $exp\n"
        ((count++))
    fi
done
echo "╭──────────────────────────────────────────╮"
echo "│            username | expired            │"
echo "╰──────────────────────────────────────────╯"
echo -e "$existing_users" | column -t -s $'\n'
echo -e "╰──────────────────────────────────────────╯"
read -n 1 -s -r -p "Press any key to continue..."
menu-vless