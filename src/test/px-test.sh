#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/px-config.sh

print_prompt() {
    log_test "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Pixie. ${CC}"

}

# This function checks the status of the Pixie Vizier component. The healthy status is defined by status "CS_HEALTHY"
check_vizier() {

    log_test "${CYAN}[INFO]" "[TEST]" "Pixie Check Vizier. ${CC}"
    
    # Authentication of pixie CLI
    px auth login --api_key "$PX_API_KEY"

    #TODO: [noman-xg] check specifically against the name of the cluster instead of tailing.
    # Get status of Vizier.
    vizier_status=$(px get viziers -o json | jq -c '. | select(.ClusterName == "xgrid-website-migration") | .Status')
    
    # check if Vizier is in healthy state or not.
    if [ "$vizier_status" -ne 1 ]; then
        log_test "${RED}[FAILED]" "[TEST]" "Pixie Vizier is not healthy state.${CC}"
    else
        log_test "${GREEN}[PASSED]" "[TEST]" "Pixie Vizier is in healthy state.${CC}"
    
    fi
}

# This function creates a test pod in the test namespace and then queries for the test pod using Pixie binary pxl script.  
# The result of the query returns true/false which determines whether Pixie is functional inside the cluster or not.
px_demo_action() {

    log_test "${CYAN}[INFO]" "[TEST]" "Pixie Demo Action. ${CC}"

    pod_name="$PX_TEST_NS/$TEST_POD"
    # Create a namespace for testing.
    kubectl create namespace "$PX_TEST_NS"
    
    # Create a pod in the test namespace
    kubectl create -f /src/manifests/test-pod.yaml 

    #import kubeconfig -- dependancy to run px run command.
    aws eks update-kubeconfig --region ap-southeast-1 --name xgrid-website-migration

    # Execute a Pxl script to get pods info in a certain namespace. If it returns true, it means Pixie is successfully deployed and actively monitoring the cluster.
    pod_found=$(px run px/pods -o json -- --namespace "$PX_TEST_NS"  | jq --arg pod_name "$pod_name" 'select(._tableName_ == "Pods List") and select(.pod == $pod_name)')    

    if [[ $pod_found == "true" ]]; then

        log_test "${GREEN}[PASSED]" "[TEST]" "Successfully queried for test pod using Pixie. ${CC}"
    else
        log_test "${RED}[FAILED]" "[TEST]" "Could not query for test pod using Pixie. ${CC}"    
    
    fi

    #clean up 
    kubectl delete namespace "$PX_TEST_NS"
    rm -rf root/.kube/config
}

print_prompt
# An array of Pixie namespaces is passed to the function. 
pod_status_verifier "${PX_NAMESPACES[@]}"
check_vizier
px_demo_action