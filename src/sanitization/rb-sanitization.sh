#!/bin/bash

source /src/config/config.sh
source /src/commons/common-functions.sh

print_prompt() {
    log "${CYAN}[INFO]" "[SANITIZATION]" "Initiating sanitization of Robusta in your cluster.${CC}"
}

rb_sanitization() {
    if command -v helm &>/dev/null; then
        #Uninstall robusta using helm
        helm uninstall robusta > /dev/null
        log "${GREEN}[INFO]" "[SANITIZATION]" "Robusta has been deleted from your cluster${CC}"
    else
        # If Helm is not installed, print an error message and exit.
        log "${RED}[ERROR]" "[SANITIZATION]" "Helm is not installed. Exiting...${CC}"
        log "${YELLOW}[INFO]" "[SANITIZATION]" "Install Helm.${CC}"
        exit 1
    fi
}

print_prompt
rb_sanitization
