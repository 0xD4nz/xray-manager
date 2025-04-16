#!/bin/bash
#today=$(date "+%Y-%m-%d")
date=$(date -d "yesterday" +"%Y-%m-%d")
ids=$(grep -B 2 "\"exp\": \"$date\"" /etc/xray/config.json | grep -E "\"id\"|\"password\"" | awk -F'\"' '{print $4}')
file_paths=("/etc/xray/vmess" "/etc/xray/vless" "/etc/xray/ss" "/etc/xray/trojan")

for path in "${file_paths[@]}"; do
  if ls $path/*.json 1> /dev/null 2>&1; then
    for file in $path/*.json; do
      nama_file=$(basename -s .json $file)
      uuid=$(cat $file)
      for id in $ids; do
        if [ "$uuid" == "$id" ]; then
          echo "Deleting ID/Password : $id"
          sed -i "/\"id\": \"${id}\"/,/{/d; /\"password\": \"${id}\"/,/{/d" /etc/xray/config.json
          echo "Deleting username configuration : $nama_file"
          rm -f $file
          sleep 1
        fi
      done
    done
  fi
done
echo "[!] Restarting xray service..."
systemctl restart xray