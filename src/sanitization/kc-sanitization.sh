#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh

print_prompt() {
    log "${BBROWN}[INFO]" "[SANITIZATION]" "Initiating sanitization of Kubecost in your cluster.${CC}"
}

#Sanitization function for kubecost
kc_sanitization() {
    helm uninstall kubecost
    log "${GREEN}[INFO]" "[SANITIZATION]" "Kubecost has been deleted from your cluster${CC}"
}
print_prompt
kc_sanitization
