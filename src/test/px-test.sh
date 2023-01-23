#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/px-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Pixie."

}

# checks if the pods in all the pixie namespaces are runnning or not.
pod_status_verifier "$PX_NAMESPACES"

# check Vizier health on the cluster 
check_vizier() {

    vizier_status=$(px get viziers | tail -1 | awk '{print $8}')
    if [ "$vizier_status" != "CS_HEALTHY" ]; then
        log "${RED}[FAILED]" "[TEST]" "Pixie Vizier is not healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    else
        log "${RED}[PASSED]" "[TEST]" "Pixie Vizier is in healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    
    fi

}