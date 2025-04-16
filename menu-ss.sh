#!/bin/bash
clear
sleep 0.5
echo "╔═════════════════════════════╗"
echo "║      ShadowSocks Menu       ║"
echo "╚═════════════════════════════╝"
echo "1. Add ShadowSocks"
echo "2. Delete ShadowSocks"
echo "3. Check accounts"
echo "4. Exit"
echo "═══════════════════════════════"
while true; do
  read -p "Enter your choice (1/2/3): " choice
  case $choice in
    1)
      add-ss
      break;;
    2)
      del-ss
      break;;
    3)
     chk-ss.sh
     break;;
    4)
      menu
      break;;
    *)
      echo "Invalid choice. Please enter 1, 2, or 3."
      sleep 2;;
  esac
done