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

# Manual Password Input and File Creation
manual_password_input() {
    while true; do
        read -s -p "Enter your desired validator password: " VALIDATOR_PASSWORD
        echo  # New line
        read -s -p "Confirm your password: " CONFIRM_PASSWORD
        echo  # New line
        if [[ "$VALIDATOR_PASSWORD" == "$CONFIRM_PASSWORD" ]]; then
            # Create password file
            echo -e "${YELLOW}[*] Creating password file...${RESET}"
            echo "$VALIDATOR_PASSWORD" > password
            chmod 600 password  # Restrict file permissions
            break
        else
            echo -e "${RED}Passwords do not match. Please try again.${RESET}"
        fi
    done
}

# Manual IP Input
manual_ip_input() {
    while true; do
        read -p "Masukkan IP VPS anda: " VPS_IP
        if validate_ip "$VPS_IP"; then
            break
        else
            echo -e "${RED}Invalid IP address. Please try again.${RESET}"
        fi
    done
}

# Prerequisites Check
prerequisites_check() {
    echo -e "${YELLOW}[*] Checking system prerequisites...${RESET}"
    
    # Check Ubuntu/Debian
    if ! command -v apt &> /dev/null; then
        echo -e "${RED}[-] This script supports Ubuntu/Debian systems only.${RESET}"
        exit 1
    fi
    # Check root access
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[-] This script must be run as root. Use sudo.${RESET}"
        exit 1
    fi
    # Check required ports
    REQUIRED_PORTS=("8231" "8085" "7621")
    for port in "${REQUIRED_PORTS[@]}"; do
        echo -e "${YELLOW}[*] Checking port $port...${RESET}"
        ufw allow "$port"
    done
}

# Download Validator Components
download_validator_components() {
    echo -e "${YELLOW}[*] Downloading PWR Validator components...${RESET}"
    
    # Download validator.jar
    wget https://github.com/pwrlabs/PWR-Validator/releases/download/13.0.0/validator.jar
    
    # Download config.json
    wget https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json
}

# Create Systemd Service File
create_systemd_service() {
    echo -e "${YELLOW}[*] Creating systemd service file...${RESET}"
    
    cat << EOF > /etc/systemd/system/pwr-validator.service
[Unit]
Description=PWR Validator Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/java -jar $(pwd)/validator.jar "$VALIDATOR_PASSWORD" "$VPS_IP" --compression-level 0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd
    systemctl daemon-reload
    systemctl enable pwr-validator.service
    systemctl start pwr-validator.service
}

# Cleanup Function
cleanup_validator() {
    echo -e "${YELLOW}[*] Starting PWR Validator cleanup process...${RESET}"

    # Stop and disable systemd service
    systemctl stop pwr-validator.service
    systemctl disable pwr-validator.service
    rm -f /etc/systemd/system/pwr-validator.service
    systemctl daemon-reload

    # Remove validator files
    rm -f validator.jar
    rm -f config.json
    rm -f password
    
    # Close and remove firewall rules
    REQUIRED_PORTS=("8231" "8085" "7621")
    for port in "${REQUIRED_PORTS[@]}"; do
        ufw delete allow "$port"
    done
    
    # Remove log files
    rm -f nohup.out
    rm -f *.log
    
    echo -e "${GREEN}[✓] PWR Validator completely removed!${RESET}"
}

# Restart Validator Function
restart_validator() {
    echo -e "${YELLOW}[*] Restarting PWR Validator...${RESET}"
    systemctl restart pwr-validator.service
    echo -e "${GREEN}[✓] Validator restarted successfully!${RESET}"
}

# View Validator Logs
view_validator_logs() {
    echo -e "${YELLOW}[*] Displaying PWR Validator Logs...${RESET}"
    journalctl -u pwr-validator.service -f
}

# Main Installation Function
main() {
    clear
    
    # Display Logo
    display_logo
    
    echo -e "${GREEN}PWR Validator Setup${RESET}"
    
    # Manual Password Input
    manual_password_input
    
    # Manual IP Input
    manual_ip_input
    
    # Prerequisites Check
    prerequisites_check
    
    # Download Validator Components
    download_validator_components
    
    # Create and start systemd service
    create_systemd_service
    
    echo -e "${GREEN}[✓] PWR Validator setup complete!${RESET}"
    echo -e "${YELLOW}Useful Commands:${RESET}"
    echo "- Get Node Address: curl localhost:8085/address/"
    echo "- Get Private Key: sudo java -jar validator.jar get-private-key $VALIDATOR_PASSWORD"
    echo "- Restart Validator: sudo systemctl restart pwr-validator"
    echo "- Check Validator Status: sudo systemctl status pwr-validator"
    echo "- View Logs: sudo journalctl -u pwr-validator.service"
}

# Execute Main Function
main
