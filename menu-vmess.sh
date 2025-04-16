#!/bin/bash
clear
sleep 0.5
echo "╔═════════════════════════════╗"
echo "║         Vmess Menu          ║"
echo "╚═════════════════════════════╝"
echo "1. Add Vmess"
echo "2. Delete Vmess"
echo "3. Check accounts"
echo "4. Exit"
echo "═══════════════════════════════"
while true; do
  read -p "Enter your choice (1/2/3): " choice
  case $choice in
    1)
      add-vmess
      break;;
    2)
      del-vmess
      break;;
    3)
      chk-vmess
      break;;
    4)
      menu
      break;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      sleep 2;;
  esac
done