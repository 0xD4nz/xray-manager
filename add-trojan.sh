#!/bin/bash
domain=$(cat /etc/xray/domain.txt)
uuid=$(cat /proc/sys/kernel/random/uuid)
ip=$(curl -s icanhazip.com)
clear
echo "╔═════════════════════════════╗"
echo "║        Trojan Manager       ║"
echo "╚═════════════════════════════╝"
echo "• DOMAIN   : ${domain}"
echo "• IP       : ${ip}"
echo "• tls port : 443,2053,2083,2087,2096,8443"
echo "• Network  : gRPC"
echo "• Service  : Trojan gRPC"
echo "• Type     : tls"
echo "• Mode     : gun"
echo "═══════════════════════════════"
sleep 0.5
read -p $'\u27A4 Username : ' username
if [ -f "/etc/xray/trojan/$username.json" ]; then
    sleep 0.5
    clear
    echo " [ ! ] Maaf konfigurasi untuk username $username sudah ada."
    echo " [ ! ] Silahkan gunakan username lain."
    read -n 1 -s -r -p "Press any key to continue..."
    menu-trojan
else
  read -p $'\u27A4 Expired (days): ' exp
  re='^[0-9]+$'
  if ! [[ $exp =~ $re ]] ; then
     sleep 0.5
     clear
     echo " [ ! ] Expired hanya bisa diisi angka."
     read -n 1 -s -r -p "Press any key to continue..."
     sleep 0.5
     menu-trojan
  else
  expired_date=$(date -d "+$exp days" "+%Y-%m-%d")
  sed -i '/"protocol": "trojan"/,/level": 8/ s/"clients": \[/"clients": \[\n                {\n                    "password": "'"$uuid"'\",\n                    "exp": "'"$expired_date"'",\n                    "level": 8\n                },/' /etc/xray/config.json
  echo "$uuid" > /etc/xray/trojan/$username.json
  clear
  sleep 2
  echo "═══════════════════════════════"
  echo "=======   Trojan gRPC   ======="
  echo "• TAG : ${username}"
  echo "• IP : ${ip}";
  echo "• DOMAIN : ${domain}"
  echo "• TLS MODE : 443,2053,2083,2087,2096,8443"
  echo "• Level   : 8"
  echo "• Password: ${uuid}"
  echo "• Network : grpc"
  echo "• Service : Trojan gRPC"
  echo "• Service Name : trojan-grpc"
  echo "• EXPIRED : $expired_date"
  echo "═══════════════════════════════"
  echo "============= LINK ============"
  echo " [ trojan gRPC TLS ] : trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${username}"
  echo "═══════════════════════════════"
  fi
service xray restart
  read -n 1 -s -r -p "Press any key to continue..."
fi
menu-trojan