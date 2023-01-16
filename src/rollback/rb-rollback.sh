#!/bin/bash

source /src/config/config.sh
source /src/commons/common-functions.sh

print_prompt() {
    log "${CYAN}[INFO]" "[ROLLBACK]" "Initiating rollback of Robusta in your cluster.${CC}"
}

rb_rollback() {
    if command -v helm &>/dev/null; then
        #Uninstall robusta using helm
        helm uninstall robusta > /dev/null
        log "${GREEN}[INFO]" "[ROLLBACK]" "Robusta has been deleted from your cluster${CC}"
    else
        # If Helm is not installed, print an error message and exit.
        log "${RED}[ERROR]" "[ROLLBACK]" "Helm is not installed. Exiting...${CC}"
        log "${YELLOW}[INFO]" "[ROLLBACK]" "Install Helm.${CC}"
        exit 1
    fi
}

print_prompt
rb_rollback
