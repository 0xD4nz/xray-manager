#!/bin/bash
clear
sleep 0.5
echo "╔═════════════════════════════╗"
echo "║         Trojan Menu         ║"
echo "╚═════════════════════════════╝"
echo "1. Add Trojan"
echo "2. Delete Trojan"
echo "3. Check accounts"
echo "4. Exit"
echo "═══════════════════════════════"
while true; do
  read -p "Enter your choice (1/2/3): " choice
  case $choice in
    1)
      add-trojan
      break;;
    2)
      del-trojan
      break;;
    3)
      chk-trojan
      break;;
    4)
      menu
      break;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      sleep 2;;
  esac
done