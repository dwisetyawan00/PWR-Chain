#!/bin/bash

# Colors for output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Validate IP input
validate_ip() {
    local ip=$1
    local valid_ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    
    if [[ $ip =~ $valid_ip_regex ]]; then
        return 0
    else
        return 1
    fi
}

# Display Logo
display_logo() {
    echo -e "${YELLOW}[*] Downloading and displaying logo...${RESET}"
    curl -s https://raw.githubusercontent.com/dwisetyawan00/dwisetyawan00.github.io/main/logo.sh | bash
}

# Press Enter to Continue
press_enter_to_continue() {
    read -p "${YELLOW}Press Enter to continue...${RESET}" continue_key
}

# System and dependency check
system_check() {
    echo -e "${YELLOW}[*] Checking system requirements...${RESET}"
    
    # Check if Ubuntu/Debian
    if ! command -v apt &> /dev/null; then
        echo -e "${RED}[-] This script supports Ubuntu/Debian systems only.${RESET}"
        exit 1
    fi

    # Check root access
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[-] This script must be run as root. Use sudo.${RESET}"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}[*] Installing required dependencies...${RESET}"
    apt update
    apt install -y git wget curl ufw software-properties-common
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
    fi
}

# Configure firewall
configure_firewall() {
    local ports=("22" "22/tcp" "8545" "30303" "30303/udp")
    
    echo -e "${YELLOW}[*] Configuring firewall...${RESET}"
    
    for port in "${ports[@]}"; do
        ufw allow "$port" 
    done
    
    ufw enable
}

# PWR Validator Installation
install_pwr_validator() {
    local vps_ip=$1
    local validator_password=$2

    echo -e "${YELLOW}[*] Cloning PWR Validator repository...${RESET}"
    git clone https://github.com/pwrlabs/PWR-Validator.git /opt/pwr-validator
    cd /opt/pwr-validator

    echo -e "${YELLOW}[*] Preparing validator configuration...${RESET}"
    cat > .env << EOL
VALIDATOR_IP=$vps_ip
VALIDATOR_PASSWORD=$validator_password
EOL
}

# Create systemd service
create_systemd_service() {
    echo -e "${YELLOW}[*] Creating systemd service for PWR Validator...${RESET}"
    
    cat > /etc/systemd/system/pwr-validator.service << EOL
[Unit]
Description=PWR Validator Service
After=docker.service
Requires=docker.service

[Service]
Type=simple
WorkingDirectory=/opt/pwr-validator
ExecStart=/usr/bin/docker-compose up
ExecStop=/usr/bin/docker-compose down
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

    systemctl daemon-reload
    systemctl enable pwr-validator
    systemctl start pwr-validator
}

# Main installation function
main() {
    clear
    
    # Display Logo
    display_logo
    
    # Press Enter to Continue
    press_enter_to_continue
    
    echo -e "${GREEN}PWR Validator Automated Installer${RESET}"
    
    # Input VPS IP
    while true; do
        read -p "Enter your VPS IP address: " VPS_IP
        if validate_ip "$VPS_IP"; then
            break
        else
            echo -e "${RED}Invalid IP address. Please try again.${RESET}"
        fi
    done

    # Input Validator Password
    read -p "Enter desired validator password: " VALIDATOR_PASSWORD

    system_check
    install_dependencies
    configure_firewall
    install_pwr_validator "$VPS_IP" "$VALIDATOR_PASSWORD"
    create_systemd_service

    echo -e "${GREEN}[✓] PWR Validator installation complete!${RESET}"
    echo -e "${YELLOW}You can manage the service with:${RESET}"
    echo "- systemctl start pwr-validator"
    echo "- systemctl stop pwr-validator"
    echo "- systemctl restart pwr-validator"
    echo "- systemctl status pwr-validator"
}

# Run main function
main
