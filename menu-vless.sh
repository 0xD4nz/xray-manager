#!/bin/bash
clear
sleep 0.5
echo "╔═════════════════════════════╗"
echo "║         Vless Menu          ║"
echo "╚═════════════════════════════╝"
echo "1. Add Vless"
echo "2. Delete Vless"
echo "3. Check accounts"
echo "4. Exit"
echo "═══════════════════════════════"
while true; do
  read -p "Enter your choice (1/2/3): " choice
  case $choice in
    1)
      add-vless
      break;;
    2)
      del-vless
      break;;
    3)
      chk-vless
      break;;
    4)
      menu
      break;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      sleep 2;;
  esac
done