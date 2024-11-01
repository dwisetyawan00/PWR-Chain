#!/bin/bash

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[34m"
BLUE="\e[34m"
RESET="\e[0m"

# Utility functions
exists() {
    command -v "$1" >/dev/null 2>&1
}

log() {
    local type="$1"
    local message="$2"
    local color

    case "$type" in
        info) color="$BLUE" ;;
        success) color="$GREEN" ;;
        error) color="$RED" ;;
        warning) color="$YELLOW" ;;
        *) color="$RESET" ;;
    esac

    echo -e "${color}${message}${RESET}"
}

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

# Manual Password Input and File Creation
manual_password_input() {
    while true; do
        read -s -p "Masukkan passwordmu: " VALIDATOR_PASSWORD
        echo  # New line
        read -s -p "Konfirmasi passwordmu: " CONFIRM_PASSWORD
        echo  # New line
        if [[ "$VALIDATOR_PASSWORD" == "$CONFIRM_PASSWORD" ]]; then
            # Create password file
            log "info" "Creating password file..."
            echo -n "$VALIDATOR_PASSWORD" > password
            chmod 600 password  # Restrict file permissions
            break
        else
            log "error" "Passwords do not match. Please try again."
        fi
    done
}

# Manual IP Input
manual_ip_input() {
    while true; do
        read -p "Enter your server IP: " VPS_IP
        if validate_ip "$VPS_IP"; then
            break
        else
            log "error" "Invalid IP address. Please try again."
        fi
    done
}

# Prerequisites Check and Installation
install_prerequisites() {
    log "info" "Updating and upgrading system..."
    sudo apt update && sudo apt upgrade -y

    local packages=(curl wget ufw openjdk-19-jre-headless)
    
    for package in "${packages[@]}"; do
        if ! exists "$package"; then
            log "info" "Installing $package..."
            sudo apt install -y "$package"
        else
            log "success" "$package is already installed."
        fi
    done
}

# Firewall Configuration
configure_firewall() {
    log "info" "Configuring firewall..."
    sudo ufw enable
    
    local ports=("22/tcp" "8231/tcp" "8085/tcp" "7621/udp")
    for port in "${ports[@]}"; do
        sudo ufw allow "$port"
    done
}

# Download Validator Components
download_validator_components() {
    log "info" "Downloading PWR Validator components..."
    
    # Download validator.jar from the correct release URL
    wget https://github.com/pwrlabs/PWR-Validator/releases/download/13.0.0/validator.jar
    
    # Download config.json from the correct repository path
    wget https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json
    
    # Verify downloads
    if [[ -f validator.jar && -f config.json ]]; then
        log "success" "Validator components downloaded successfully"
    else
        log "error" "Failed to download validator components"
        exit 1
    fi
}

# Create Systemd Service
create_systemd_service() {
    log "info" "Creating systemd service..."
    
    sudo tee /etc/systemd/system/pwr.service > /dev/null <<EOF
[Unit]
Description=PWR node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$PWD
ExecStart=/usr/bin/java -jar validator.jar password $VPS_IP --compression-level 0
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable pwr.service
    sudo systemctl start pwr.service
}

# Main Installation Function
main() {
    clear
    
    # Display Logo
    log "info" "Downloading and displaying logo..."
    curl -s https://raw.githubusercontent.com/dwisetyawan00/dwisetyawan00.github.io/main/logo.sh | bash
    sleep 2
    
    log "info" "Memulai PWR Validator Setup..."
    
    # Install prerequisites
    install_prerequisites
    
    # Manual Password Input
    manual_password_input
    
    # Manual IP Input
    manual_ip_input
    
    # Configure Firewall
    configure_firewall
    
    # Download Components
    download_validator_components
    
    # Create and Start Service
    create_systemd_service
    
    log "success" "PWR Validator setup complete!"
    log "info" "Useful Commands:"
    echo "- Get Node Address: curl localhost:8085/address/"
    echo "- Get Private Key: sudo java -jar validator.jar get-private-key password"
    echo "- Check Service Status: sudo systemctl status pwr"
    echo "- View Logs: sudo journalctl -u pwr -f"
    echo "- Restart Service: sudo systemctl restart pwr"
}

# Execute Main Function
main
