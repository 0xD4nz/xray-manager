#!/bin/bash
clear
echo "[!] Disabling BBR and restoring previous settings...."
sleep 1
sudo modprobe -r tcp_bbr > /dev/null 2>&1
sudo sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf > /dev/null
sudo sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf > /dev/null
sudo sysctl -p > /dev/null

echo "[+] BBR is now disabled, and settings are restored to the previous state."
seconds=5
while [ $seconds -gt 0 ]; do
  echo -ne "Rebooting system on: $seconds\r"
  sleep 1
  ((seconds--))
done
reboot