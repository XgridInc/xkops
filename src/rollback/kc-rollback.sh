#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh

print_prompt() {
    log "${BBROWN}[INFO]" "[ROLLBACK]" "Initiating rollback of Kubecost in your cluster.${CC}"
}

#Rollback function for kubecost
kc_rollback() {
    helm uninstall kubecost
    log "${GREEN}[INFO]" "[ROLLBACK]" "Kubecost has been deleted from your cluster${CC}"
}
print_prompt
kc_rollback
