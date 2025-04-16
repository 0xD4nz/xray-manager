#!/bin/bash
domain=$(cat /etc/xray/domain.txt)
uuid=$(cat /proc/sys/kernel/random/uuid)
ip=$(curl -s icanhazip.com)
clear
echo "╔═════════════════════════════╗"
echo "║         Vless Manager       ║"
echo "╚═════════════════════════════╝"
echo "• DOMAIN   : ${domain}"
echo "• IP       : ${ip}"
echo "• non tls  : 80,2052,2086,2095,8080,8888"
echo "• tls port : 443,2053,2083,2087,2096,8443"
echo "• Network  : ws"
echo "• Service  : vless websocket"
echo "• Type     : tls&nontls"
echo "═══════════════════════════════"
sleep 0.5
read -p $'\u27A4 Username : ' username
if [ -f "/etc/xray/vless/$username.json" ]; then
    sleep 0.5
    clear
    echo " [ ! ] Maaf konfigurasi untuk username $username sudah ada."
    echo " [ ! ] Silahkan gunakan username lain."
    read -n 1 -s -r -p "Press any key to continue..."
    menu-vless
else
  read -p $'\u27A4 Expired (days): ' exp
  re='^[0-9]+$'
  if ! [[ $exp =~ $re ]] ; then
     sleep 0.5
     clear
     echo " [ ! ] Expired hanya bisa diisi angka."
     read -n 1 -s -r -p "Press any key to continue..."
     sleep 0.5
     menu-vless
  else
  expired_date=$(date -d "+$exp days" "+%Y-%m-%d")
  sed -i '/"protocol": "vless"/,/level": 0/ s/"clients": \[/"clients": \[\n                {\n                    "id": "'"$uuid"'",\n                    "exp": "'"$expired_date"'",\n                    "level": 0\n                },/' /etc/xray/config.json
  echo "$uuid" > /etc/xray/vless/$username.json
  clear
  sleep 2
  echo "═══════════════════════════════"
  echo "======= Vless Websocket ======="
  echo "• TAG : ${username}"
  echo "• IP : ${ip}";
  echo "• DOMAIN : ${domain}"
  echo "• NON TLS  : 80,2052,2086,2095,8080,8888"
  echo "• TLS MODE : 443,2053,2083,2087,2096,8443"
  echo "• ID : ${uuid}"
  echo "• LEVEL : 0"
  echo "• NETWORK : ws"
  echo "• PATH : /vless-ws"
  echo "• EXPIRED : $expired_date"
  echo "═══════════════════════════════"
  echo "======= Vmess Websocket ======="
  echo " [ NON TLS ] : vless://${uuid}@${domain}:80?path=%2Fvless-ws&security=none&encryption=none&host=${domain}&type=ws#${username}-ntls"
  echo " [ TLS MODE ] : vless://${uuid}@${domain}:443?path=%2Fvless-ws&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${username}-tls"
  echo "═══════════════════════════════"
  fi
service xray restart
  read -n 1 -s -r -p "Press any key to continue..."
fi
menu-vless