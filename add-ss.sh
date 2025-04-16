#!/bin/bash
domain=$(cat /etc/xray/domain.txt)
uuid=$(cat /proc/sys/kernel/random/uuid)
ip=$(curl -s icanhazip.com)
clear
# Display stylish header
echo "╔═════════════════════════════╗"
echo "║      ShadowSocks Manager    ║"
echo "╚═════════════════════════════╝"
echo "• DOMAIN   : ${domain}"
echo "• IP       : ${ip}"
echo "• non tls  : 80,2052,2086,2095,8080,8888"
echo "• tls port : 443,2053,2083,2087,2096,8443"
echo "• Network  : websocket"
echo "• Service  : SS ws"
echo "• Type     : tls&nontls"
echo "═══════════════════════════════"
sleep 0.5
read -p $'\u27A4 Username : ' username
if [ -f "/etc/xray/ss/$username.json" ]; then
    sleep 0.5
    clear
    echo " [ ! ] Maaf konfigurasi untuk username $username sudah ada."
    echo " [ ! ] Silahkan gunakan username lain."
    read -n 1 -s -r -p "Press any key to continue..."
    menu-ss
else
  read -p $'\u27A4 Expired (days): ' exp
  re='^[0-9]+$'
  if ! [[ $exp =~ $re ]] ; then
     sleep 0.5
     clear
     echo " [ ! ] Expired hanya bisa diisi angka."
     read -n 1 -s -r -p "Press any key to continue..."
     sleep 0.5
     menu-ss
  else
  expired_date=$(date -d "+$exp days" "+%Y-%m-%d")
  sed -i '/"protocol": "shadowsocks"/,/decryption": "none"/ s/"clients": \[/"clients": \[\n                {\n                    "password": "'"$uuid"'",\n                    "exp": "'$expired_date'\",\n                    "method": "chacha20-ietf-poly1305"\n                },/' /etc/xray/config.json
  echo "$uuid" > /etc/xray/ss/$username.json
  clear
  sleep 2
  echo "═══════════════════════════════"
  echo "=======   Ss Websocket  ======="
  echo "• TAG : ${username}"
  echo "• IP : ${ip}";
  echo "• DOMAIN : ${domain}"
  echo "• non tls  : 80,2052,2086,2095,8080,8888"
  echo "• TLS MODE : 443,2053,2083,2087,2096,8443"
  echo "• method : chacha20-ietf-poly1305"
  echo "• Password: ${uuid}"
  echo "• Network : websocket"
  echo "• Service : Ss Ws"
  echo "• Path : /ss-ws"
  echo "• EXPIRED : $expired_date"
  echo "• Note : mux must be enabled"
  echo "═══════════════════════════════"
  echo "============= LINK ============"
  echo " [ SS WEBSOCKET NONTLS ] : ss://$(echo -n "chacha20-ietf-poly1305:$uuid" | base64 -w 0)=@$domain:80?path=%2Fss-ws&security=none&host=$domain&type=ws#$username-ntls"
  echo " [ SS WEBSOCKET TLS ] : ss://$(echo -n "chacha20-ietf-poly1305:$uuid" | base64 -w 0)=@$domain:443?path=%2Fss-ws&security=tls&host=$domain&type=ws&sni=$domain#$username-tls"
  echo "═══════════════════════════════"
  fi
  service xray restart
  read -n 1 -s -r -p "Press any key to continue..."
fi
menu-ss