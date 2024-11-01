#!/bin/bash

# Colors for output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Cleanup Function
cleanup_validator() {
    echo -e "${YELLOW}[*] Starting PWR Validator cleanup process...${RESET}"

    # Stop any running validator processes
    echo -e "${YELLOW}[*] Stopping validator processes...${RESET}"
    pkill -f "validator.jar"
    
    # Remove validator files
    echo -e "${YELLOW}[*] Removing validator files...${RESET}"
    rm -f validator.jar
    rm -f config.json
    rm -f password
    
    # Close and remove firewall rules
    echo -e "${YELLOW}[*] Removing firewall rules...${RESET}"
    ufw delete allow 8231
    ufw delete allow 8085
    ufw delete allow 7621
    
    # Optional: Remove any hidden or log files
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
