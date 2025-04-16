#!/bin/bash
domain=$(cat /etc/xray/domain.txt)
uuid=$(cat /proc/sys/kernel/random/uuid)
ip=$(curl -s icanhazip.com)
clear
echo "╔═════════════════════════════╗"
echo "║         Vmess Manager       ║"
echo "╚═════════════════════════════╝"
echo "• DOMAIN   : ${domain}"
echo "• IP       : ${ip}"
echo "• non tls  : 80,2052,2086,2095,8080,8888"
echo "• tls port : 443,2053,2083,2087,2096,8443"
echo "• Network  : ws"
echo "• Service  : vmess websocket"
echo "• Type     : tls&nontls"
echo "═══════════════════════════════"
sleep 0.5
read -p $'\u27A4 Username : ' username
if [ -f "/etc/xray/vmess/$username.json" ]; then
    sleep 0.5
    clear
    echo " [ ! ] Maaf konfigurasi untuk username $username sudah ada."
    echo " [ ! ] Silahkan gunakan username lain."
    read -n 1 -s -r -p "Press any key to continue..."
    menu-vmess
else
  read -p $'\u27A4 Expired (days): ' exp
  re='^[0-9]+$'
  if ! [[ $exp =~ $re ]] ; then
     sleep 0.5
     clear
     echo " [ ! ] Expired hanya bisa diisi angka."
     read -n 1 -s -r -p "Press any key to continue..."
     sleep 0.5
     menu-vmess
  else
  expired_date=$(date -d "+$exp days" "+%Y-%m-%d")
  sed -i '/"protocol": "vmess"/,/alterId": 0/ s/"clients": \[/"clients": \[\n                {\n                    "id": "'"$uuid"'",\n                    "exp": "'"$expired_date"'",\n                    "alterId": 0\n                },/' /etc/xray/config.json
  echo "$uuid" > /etc/xray/vmess/$username.json
  nontls="{\"add\":\"${domain}\",\"aid\":\"0\",\"alpn\":\"\",\"fp\":\"\",\"host\":\"${domain}\",\"id\":\"${uuid}\",\"net\":\"ws\",\"path\":\"/vmess-ws\",\"port\":\"80\",\"ps\":\"${username}-ntls\",\"scy\":\"auto\",\"sni\":\"\",\"tls\":\"\",\"type\":\"\",\"v\":\"2\"}"
  tlsmode="{\"add\":\"${domain}\",\"aid\":\"0\",\"alpn\":\"\",\"fp\":\"\",\"host\":\"${domain}\",\"id\":\"${uuid}\",\"net\":\"ws\",\"path\":\"/vmess-ws\",\"port\":\"443\",\"ps\":\"${username}-tls\",\"scy\":\"auto\",\"sni\":\"${domain}\",\"tls\":\"tls\",\"type\":\"\",\"v\":\"2\"}"
  clear
  sleep 2
  echo "═══════════════════════════════"
  echo "======= Vmess Websocket ======="
  echo "• TAG : ${username}"
  echo "• IP : ${ip}";
  echo "• DOMAIN : ${domain}"
  echo "• NON TLS  : 80,2052,2086,2095,8080,8888"
  echo "• TLS MODE : 443,2053,2083,2087,2096,8443"
  echo "• UUID : ${uuid}"
  echo "• ALTERID : 0"
  echo "• NETWORK : ws"
  echo "• PATH : /vmess-ws"
  echo "• EXPIRED : $expired_date"
  echo "═══════════════════════════════"
  echo "============= LINK ============"
  echo " [ NON TLS ] : vmess://$(echo -n "$nontls" | base64 -w 0)"
  echo " [ TLS MODE ] : vmess://$(echo -n "$tlsmode" | base64 -w 0)"
  echo "═══════════════════════════════"
  fi
  service xray restart
  read -n 1 -s -r -p "Press any key to continue..."
fi
menu-vmess