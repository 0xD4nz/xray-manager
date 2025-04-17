#!/bin/bash

# Constants
CONFIG_URL="https://gitlab.com/HiWorld/xray/-/raw/main"
TIMEZONE="Asia/Jakarta"
SWAP_SIZE="1G"
EMAIL="ardanferdi19@gmail.com"
ACME_SERVERS=("letsencrypt" "buypass" "zerossl") # List of ACME servers to try
LOG_FILE="/var/log/xray-install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize logging
setup_logging() {
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
    exec > >(tee -a "$LOG_FILE") 2>&1
    log_info "Installation started at $(date)"
}

# Functions
log_info() {
    echo -e "${BLUE}[*] ${1}${NC}"
    logger -t xray-install "[INFO] ${1}"
}

log_success() {
    echo -e "${GREEN}[+] ${1}${NC}"
    logger -t xray-install "[SUCCESS] ${1}"
}

log_warning() {
    echo -e "${YELLOW}[!] ${1}${NC}"
    logger -t xray-install "[WARNING] ${1}"
}

log_error() {
    echo -e "${RED}[!] ${1}${NC}"
    logger -t xray-install "[ERROR] ${1}"
}

confirm_reboot() {
    echo ""
    log_warning "Some changes may require a reboot to take effect"
    read -p "Do you want to reboot now? (y/N) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "System will reboot in 5 seconds..."
        sleep 5
        reboot
    else
        log_info "You can manually reboot later using: sudo reboot"
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run this script as root user!"
        exit 1
    fi
    log_success "Permission accepted"
}

check_domain() {
    if [ -f "/etc/xray/domain.txt" ]; then
        local existing_domain=$(cat /etc/xray/domain.txt)
        log_info "Existing domain found: $existing_domain"
        
        # Verify if the domain still points to this server
        local current_ip=$(curl -s ifconfig.me)
        local domain_ip=$(dig +short "$existing_domain" | head -1)
        
        if [ "$domain_ip" == "$current_ip" ]; then
            log_success "Domain $existing_domain is already configured and points to this server"
            return 0
        else
            log_warning "Domain $existing_domain does not point to this server's IP ($current_ip)"
            return 1
        fi
    fi
    return 1
}

install_packages() {
    local packages=(
        nginx cron zip unzip dpkg curl wget 
        systemd-timesyncd python3 socat 
        net-tools speedtest-cli vnstat ntp dnsutils jq
    )

    log_info "Updating repository"
    if ! apt update && apt upgrade -y; then
        log_error "Failed to update repository"
        return 1
    fi

    log_info "Installing required packages"
    
    # Install all packages at once and handle failure
    if ! apt install -y "${packages[@]}"; then
        log_warning "Some packages failed to install, retrying individually..."
        
        for pkg in "${packages[@]}"; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                log_warning "Retrying installation for: $pkg"
                if ! apt install -y "$pkg"; then
                    log_error "Failed to install $pkg, skipping..."
                else
                    log_success "Successfully installed $pkg"
                fi
            else
                log_success "$pkg is already installed"
            fi
        done
    fi
}

setup_timezone() {
    log_info "Setting up time zone"
    if timedatectl set-timezone "$TIMEZONE"; then
        log_success "Timezone set to $TIMEZONE"
    else
        log_error "Failed to set timezone"
    return 1
    fi
}

create_swap() {
    log_info "Creating swapfile"
    if [ ! -f /swapfile ]; then
        if fallocate -l "$SWAP_SIZE" /swapfile && \
           chmod 600 /swapfile && \
           mkswap /swapfile && \
           swapon /swapfile && \
           echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab; then
            log_success "Swapfile created successfully"
        else
            log_error "Failed to create swapfile"
            return 1
        fi
    else
        log_warning "Swapfile already exists, skipping creation"
    fi
}

install_xray() {
    log_info "Installing Xray & setting up configuration"
    local xray_latest="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
    
    if ! wget -q "$xray_latest"; then
        log_error "Failed to download Xray"
        return 1
    fi
    
    if ! unzip -q Xray-linux-64.zip -d /usr/bin/; then
        log_error "Failed to unzip Xray"
        return 1
    fi
    rm -f Xray-linux-64.zip
    
    mkdir -p /etc/xray/{vless,vmess,ss,trojan} /var/log/xray
    
    if ! wget -q -O /etc/xray/config.json "${CONFIG_URL}/config.json"; then
        log_error "Failed to download Xray config"
        return 1
    fi
    
    cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=xray Service
After=network.target

[Service]
User=root
Group=root
Restart=always
ExecStart=/usr/bin/xray run -c /etc/xray/config.json
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

    log_success "Xray installed successfully"
}

generate_certificate() {
    local domain=""
    
    # Check if domain already exists and is valid
    if check_domain; then
        log_info "Using existing domain configuration"
        domain=$(cat /etc/xray/domain.txt)
        return 0
    fi
    
    while true; do
        read -p "Input Domain: " domain
        
        if [ -z "$domain" ]; then
            log_error "Domain cannot be empty"
            continue
        fi
        
        # Verify domain points to this server
        local current_ip=$(curl -s ifconfig.me)
        local domain_ip=$(dig +short "$domain" | head -1)
        
        if [ "$domain_ip" != "$current_ip" ]; then
            log_error "Domain $domain does not point to this server's IP ($current_ip)"
            log_info "Please update your DNS records first"
            continue
        fi
        
        log_info "Stopping nginx..."
        systemctl stop nginx
        
        log_info "Installing acme.sh"
        if ! curl -s https://get.acme.sh | sh; then
            log_error "Failed to install acme.sh"
            return 1
        fi
        
        source ~/.bashrc
        
        log_info "Registering acme.sh account"
        if ! ~/.acme.sh/acme.sh --register-account -m "$EMAIL"; then
            log_error "Failed to register acme.sh account"
            return 1
        fi
        
        # Try different ACME servers
        local cert_success=0
        for server in "${ACME_SERVERS[@]}"; do
            log_info "Trying to issue certificate using $server..."
            
            if ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --server "$server" \
                --key-file /etc/xray/xray.key \
                --fullchain-file /etc/xray/xray.crt; then
                log_success "Certificate generated successfully using $server"
                echo "$domain" > /etc/xray/domain.txt
                cert_success=1
                break
            else
                log_warning "Failed to generate certificate with $server"
            fi
        done
        
        if [ "$cert_success" -eq 1 ]; then
            return 0
        fi
        
        log_error "All certificate generation attempts failed"
        log_info "Please check:"
        log_info "1. Your domain is properly pointed to this server's IP"
        log_info "2. Port 80 is not blocked by firewall"
        log_info "3. The domain is not already registered with these services"
        
        read -p "Do you want to try again? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Certificate generation aborted"
            return 1
        fi
    done
}

setup_nginx() {
    log_info "Setting up nginx server"
    if ! wget -q -O /etc/nginx/nginx.conf "${CONFIG_URL}/nginx.conf"; then
        log_error "Failed to download nginx.conf"
        return 1
    fi
    
    if ! wget -q -O /etc/nginx/conf.d/xray.conf "${CONFIG_URL}/xray.conf"; then
        log_error "Failed to download xray.conf"
        return 1
    fi
    
    if ! wget -q -O /var/www/html/index.html "${CONFIG_URL}/index.html"; then
        log_error "Failed to download index.html"
        return 1
    fi
    
    log_success "Nginx configured successfully"
}

setup_cron() {
    log_info "Setting up auto exp"
    if ! wget -q -O /etc/xray/auto-exp "${CONFIG_URL}/auto-exp.sh"; then
        log_error "Failed to download auto-exp script"
        return 1
    fi
    
    chmod +x /etc/xray/auto-exp
    echo "0 0 * * * root /etc/xray/auto-exp" | tee -a /etc/crontab > /dev/null
    systemctl restart cron
    
    log_success "Cron job set up successfully"
}

download_scripts() {
    local scripts=(
        add-vmess add-vless add-trojan add-ss
        menu-vmess menu-vless menu-trojan menu-ss
        del-vmess del-vless del-trojan del-ss
        chk-vmess chk-vless chk-trojan chk-ss
        enable-bbr disable-bbr service-restart bw-usage menu
    )
    
    log_info "Downloading menu scripts"
    
    for script in "${scripts[@]}"; do
        if ! wget -q -O "/usr/bin/$script" "${CONFIG_URL}/${script}.sh"; then
            log_error "Failed to download $script"
            continue
        fi
        chmod +x "/usr/bin/$script"
        log_success "Downloaded and made executable: $script"
    done
    
    cat >> ~/.bashrc <<EOF
clear && menu
EOF
    
    log_success "All scripts downloaded and configured"
}

enable_services() {
    log_info "Enabling services"
    if ! systemctl daemon-reload || \
       ! systemctl enable xray nginx; then
        log_error "Failed to enable services"
        return 1
    fi
    
    log_info "Restarting services"
    if ! systemctl restart xray nginx; then
        log_error "Failed to restart services"
        return 1
    fi
    
    log_success "Services enabled and started successfully"
}

disable_ipv6() {
    log_info "Disabling IPv6"
    if sysctl -w net.ipv6.conf.all.disable_ipv6=1 && \
       sysctl -w net.ipv6.conf.default.disable_ipv6=1 && \
       echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && \
       echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf; then
        log_success "IPv6 disabled successfully"
    else
        log_error "Failed to disable IPv6"
        return 1
    fi
}

show_summary() {
    local domain=""
    if [ -f "/etc/xray/domain.txt" ]; then
        domain=$(cat /etc/xray/domain.txt)
    fi
    
    echo ""
    echo -e "${GREEN}=== Installation Summary ==="
    log_info "Server IP: $(curl -s ifconfig.me)"
    log_info "Domain: ${domain:-Not set}"
    log_info "Xray status: $(systemctl is-active xray)"
    log_info "Nginx status: $(systemctl is-active nginx)"
    log_info "Installation log: $LOG_FILE"
    echo -e "============================${NC}"
    echo ""
}

main() {
    setup_logging
    clear
    check_root
    sleep 1
    
    disable_ipv6
    sleep 0.5
    
    install_packages
    clear
    
    setup_timezone
    sleep 0.5
    
    create_swap
    sleep 0.5
    
    install_xray
    sleep 0.5
    clear
    
    generate_certificate
    sleep 3
    clear
    
    setup_nginx
    sleep 1
    clear
    
    setup_cron
    download_scripts
    sleep 0.5
    clear
    
    enable_services
    sleep 1
    clear
    
    log_success "Installation completed successfully!"
    show_summary
    
    confirm_reboot
}

main