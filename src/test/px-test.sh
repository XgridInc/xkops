#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/px-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Pixie."

}

# This function checks the status of the Pixie Vizier component. The healthy status is defined by status "CS_HEALTHY"
check_vizier() {

    log "${CYAN}[INFO]" "[TEST]" "Pixie Check Vizier."
    
    # Authentication of pixie CLI
    px auth login --api_key "$PX_API_KEY"

    #TODO: [noman-xg] check specifically against the name of the cluster instead of tailing.
    # Get status of Vizier.
    vizier_status=$(px get viziers | tail -1 | awk '{print $8}')
    
    # check if Vizier is in healthy state or not.
    if [ "$vizier_status" != "CS_HEALTHY" ]; then
        log "${RED}[FAILED]" "[TEST]" "Pixie Vizier is not healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    else
        log "${GREEN}[PASSED]" "[TEST]" "Pixie Vizier is in healthy state.${CC}${YELLOW} Vizier Status: $vizier_status ${CC}"
    
    fi
}

px_demo_action() {

    log "${CYAN}[INFO]" "[TEST]" "Pixie Demo Action."

    pod_name="$PX_TEST_NS/$TEST_POD"
    # Create a namespace for testing.
    kubectl create namespace "$PX_TEST_NS"
    
    # Create a pod in the test namespace
    kubectl create -f /src/manifests/test-pod.yaml 

    # Execute a Pxl script to get pods info in a certain namespace. If it returns true, it means Pixie is successfully deployed and actively monitoring the cluster.
    pod_found=$(px run px/pods -o json -- --namespace default  | jq --arg pod_name "$pod_name" 'select(._tableName_ == "Pods List") and select(.pod == $pod_name)')    

    if [[ $pod_found == "true" ]]; then

        log "${GREEN}[PASSED]" "[TEST]" "Successfully queried for test pod using Pixie."
    else
        log "${RED}[FAILED]" "[TEST]" "Could not query for test pod using Pixie."    
    
    fi

    #clean up 
    kubectl delete namespace "$PX_TEST_NS"
}

print_prompt
# An array of Pixie namespaces is passed to the function. 
pod_status_verifier "${PX_NAMESPACES[@]}"
check_vizier
px_demo_action