#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[ROLLBACK]" "Initiating rollback of Kubecost in your cluster.${CC}"
}

#Rollback function for kubecost
kc_rollback() {
    helm uninstall kubecost -n kubecost &>/dev/null
    kubectl delete namespace kubecost &>/dev/null
    log "${GREEN}[PASSED]" "[ROLLBACK]" "Kubecost has been deleted from your cluster${CC}"
}
print_prompt
kc_rollback
