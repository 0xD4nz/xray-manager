#!/bin/bash
clear
echo "[!] Restarting all services...."
sleep 0.5
systemctl restart xray
systemctl restart nginx
systemctl restart cron
echo -e "[!] Checking service status...\n"
sleep 0.5
if systemctl is-active --quiet xray; then
  echo "[+]xray service is running."
else
  echo "[!]xray service is not running."
fi
sleep 0.5
if systemctl is-active --quiet nginx; then
  echo "[+]nginx service is running."
else
  echo "[!]nginx service is not running."
fi
sleep 0.5
if systemctl is-active --quiet cron; then
  echo "[+]cron service is running."
else
  echo "[!]cron service is not running."
fi
sleep 5
menu