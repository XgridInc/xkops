#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/px-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Pixie."

}

# This function checks the status of the Pixie Vizier component. The healthy status is defined by status "CS_HEALTHY"
check_vizier() {
    
    # authentication of pixie CLI
    px auth login --api_key "$PX_API_KEY"

    #TODO: [noman-xg] check specifically against the name of the cluster instead of tailing.
    # get status of Vizier.
    vizier_status=$(px get viziers | tail -1 | awk '{print $8}')
    
    # check if Vizier is in healthy state or not.
    if [ "$vizier_status" != "CS_HEALTHY" ]; then
        log "${RED}[FAILED]" "[TEST]" "Pixie Vizier is not healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    else
        log "${GREEN}[PASSED]" "[TEST]" "Pixie Vizier is in healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    
    fi
}

print_prompt
# An array of Pixie namespaces is passed to the function. 
pod_status_verifier "${PX_NAMESPACES[@]}"
check_vizier
