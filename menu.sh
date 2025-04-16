#!/bin/bash
clear

# Color definitions
c='\e[96m'     # Cyan
gb='\e[1;92m'  # Green Bold
p='\e[95m'     # Purple
r='\e[91m'     # Red
rb='\e[41m'    # Red Background
wb='\e[1;97m'  # White Bold
yb='\e[1;93m'  # Yellow Bold
nc='\e[0m'     # No Color

# System information functions
get_system_info() {
    OS=$(awk -F= '/PRETTY_NAME/{print $2}' /etc/os-release | tr -d \")
    RAM=$(free -h | awk '/Mem/{printf "%-5s / %-5s (%.1f%%)", $2, $3, $3/$2 * 100}')
    CPU=$(grep -c processor /proc/cpuinfo)" Core(s)"
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8"%"}')
    UPTIME=$(uptime -p)
    TIME=$(date +"%A, %d %B %Y %T %Z")
    VKERNEL=$(uname -r)
    TCP_CC=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
}

get_network_info() {
    local ipapi_data
    ipinfo_data=$(curl -s https://ipinfo.io/json)
    ISP=$(jq -r '.org' <<< "$ipinfo_data")
    CITY=$(jq -r '.city' <<< "$ipinfo_data")
    IP=$(jq -r '.ip' <<< "$ipinfo_data")
    DOMAIN=$(cat /etc/xray/domain.txt 2>/dev/null || echo "Not configured")
}

service_status() {
    systemctl is-active --quiet "$1" && echo "${gb}Active${nc}" || echo "${r}Inactive${nc}"
}

count_configs() {
    local protocol=$1
    ls -1 "/etc/xray/$protocol"/*.json 2>/dev/null | wc -l
}

display_box() {
    local title=$1 content=$2
    echo -e "${c}╔════════════════════════════════════╗${nc}"
    echo -e "${c}║${rb}${wb}${title}${nc}${c}║${nc}"
    echo -e "${c}╟────────────────────────────────────╢${nc}"
    echo -e "$content"
    echo -e "${c}╙────────────────────────────────────╜${nc}"
}

display_menu() {
    # System info box
    display_box "        System Configuration        " \
    "${c}║ OS: ${nc}$OS
${c}║ KERNEL VERSION: ${nc}$VKERNEL
${c}║ TCP CC: ${nc}$TCP_CC
${c}║ RAM: ${nc}$RAM
${c}║ CPU: ${nc}$CPU
${c}║ CPU USAGE: ${nc}$CPU_USAGE
${c}║ UPTIME: ${nc}$UPTIME
${c}║ CURRENT TIME: ${nc}$TIME"

    # Network info box
    display_box "       Network Configuration        " \
    "${c}║ ISP: ${nc}$ISP
${c}║ City: ${nc}$CITY
${c}║ Public IP: ${nc}$IP
${c}║ Domain: ${nc}$DOMAIN"

    # Service status box
    echo -e "${c}╓────────────────────────────────────╖${nc}"
    echo -e "${c}║${p} Nginx${nc} : $(service_status nginx)     ${p}Xray${nc} : $(service_status xray)   ${nc}"
    echo -e "${c}╙────────────────────────────────────╜${nc}"

    # Protocol count box
    local vmess=$(count_configs vmess)
    local vless=$(count_configs vless)
    local trojan=$(count_configs trojan)
    local ss=$(count_configs ss)
    
    echo -e "${c}╓────────────────────────────────────╖${nc}"
    echo -e "${c}║ ${wb}vmess : ${gb}${vmess} ${nc}     ${wb}vless : ${gb}${vless} ${nc}"
    echo -e "${c}║ ${wb}trojan : ${gb}${trojan} ${nc}    ${wb}shadowsocks: ${gb}${ss} ${nc}"
    echo -e "${c}╟────────────────────────────────────╢${nc}"

    # Main menu box
    display_box "             Main Menu              " \
    "${c}║ ${wb}[1]${yb} VMESS       ${nc}║ ${wb}[00]${yb} Exit   ${nc}
${c}║ ${wb}[2]${yb} VLESS       ${nc}║
${c}║ ${wb}[3]${yb} Trojan      ${nc}║
${c}║ ${wb}[4]${yb} Shadowsocks ${nc}║
${c}║ ${wb}[5]${yb} Tools       ${nc}║ ${nc}"
}

handle_choice() {
    case $1 in
        1) menu-vmess ;;
        2) menu-vless ;;
        3) menu-trojan ;;
        4) menu-ss ;;
        5) xr-tools ;;
        00)exit ;;
        *) echo "Invalid choice."; sleep 2; menu ;;
    esac
}

# Main execution
get_system_info
get_network_info
display_menu

read -p "Enter your choice: " choice
handle_choice "$choice"
