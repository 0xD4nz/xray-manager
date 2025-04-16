#!/bin/bash
clear
kernel_version=$(uname -r | cut -d. -f1)
if [ "$kernel_version" -gt 4 ] || ([ "$kernel_version" -eq 4 ] && [ "$(uname -r | cut -d. -f2)" -gt 9 ]); then
  sudo modprobe tcp_bbr > /dev/null 2>&1
  echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf > /dev/null
  echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf > /dev/null
  sudo sysctl -p > /dev/null
  echo -e "\n[+] BBR is now enabled.\n"
else
  echo "Kernel version is not above 4.9. BBR cannot be enabled."
  menu
fi
seconds=5
while [ $seconds -gt 0 ]; do
  echo -ne "Rebooting system on: $seconds\r"
  sleep 1
  ((seconds--))
done
reboot