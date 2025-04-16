#!/bin/bash
# tools-menu.sh - Xray Tools Management

show_tools_menu() {
  clear
  sleep 0.5
  echo -e "\e[96m╔═════════════════════════════╗\e[0m"
  echo -e "\e[96m║         \e[1;97mTools Menu\e[0m\e[96m          ║\e[0m"
  echo -e "\e[96m╚═════════════════════════════╝\e[0m"
  echo -e "1. Speedtest"
  echo -e "2. Enable BBR"
  echo -e "3. Disable BBR"
  echo -e "4. Restart Services"
  echo -e "5. Bandwidth Usage"
  echo -e "6. Back to Main Menu"
  echo -e "\e[96m═══════════════════════════════\e[0m"
}

handle_tools_menu() {
  while true; do
    show_tools_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
      1)
        clear
        echo -e "\e[1;92mRunning Speedtest...\e[0m"
        speedtest --share
        read -p "Press [Enter] to return to menu"
        ;;
      2)
        clear
        echo -e "\e[1;92mEnabling BBR...\e[0m"
        enable-bbr
        read -p "Press [Enter] to return to menu"
        ;;
      3)
        clear
        echo -e "\e[1;92mDisabling BBR...\e[0m"
        disable-bbr
        read -p "Press [Enter] to return to menu"
        ;;
      4)
        clear
        echo -e "\e[1;92mRestarting Services...\e[0m"
        service-restart
        read -p "Press [Enter] to return to menu"
        ;;
      5)
        clear
        echo -e "\e[1;92mShowing Bandwidth Usage...\e[0m"
        bw-usage
        read -p "Press [Enter] to return to menu"
        ;;
      6)
        clear
        menu
        ;;
      *)
        echo -e "\e[91mInvalid choice. Please enter 1-6.\e[0m"
        sleep 2
        ;;
    esac
  done
}

# Main execution
handle_tools_menu