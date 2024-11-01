#!/bin/bash
# Colors for output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Cleanup Function
cleanup_validator() {
    echo -e "${YELLOW}[*] Starting PWR Validator cleanup process...${RESET}"

    # Stop and disable systemd service
    if systemctl is-active --quiet pwr-validator.service; then
        echo -e "${YELLOW}[*] Stopping validator service...${RESET}"
        systemctl stop pwr-validator.service
    fi

    if systemctl is-enabled --quiet pwr-validator.service; then
        echo -e "${YELLOW}[*] Disabling validator service...${RESET}"
        systemctl disable pwr-validator.service
    fi

    # Remove systemd service file
    if [ -f "/etc/systemd/system/pwr-validator.service" ]; then
        echo -e "${YELLOW}[*] Removing systemd service file...${RESET}"
        rm -f /etc/systemd/system/pwr-validator.service
        systemctl daemon-reload
    fi

    # Remove validator files
    echo -e "${YELLOW}[*] Removing validator files...${RESET}"
    rm -f validator.jar
    rm -f config.json
    rm -f password

    # Close and remove firewall rules
    echo -e "${YELLOW}[*] Removing firewall rules...${RESET}"
    REQUIRED_PORTS=("8231" "8085" "7621")
    for port in "${REQUIRED_PORTS[@]}"; do
        ufw delete allow "$port" || true
    done

    # Remove log files
    echo -e "${YELLOW}[*] Removing additional files...${RESET}"
    rm -f nohup.out
    rm -f *.log

    echo -e "${GREEN}[✓] PWR Validator completely removed!${RESET}"
}

# Check root access
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[-] This script must be run as root. Use sudo.${RESET}"
    exit 1
fi

# Execute Cleanup
cleanup_validator
