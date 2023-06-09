#!/bin/bash

# Copyright (c) 2023, Xgrid Inc, https://xgrid.co

# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    px auth login --api_key "$PX_API_KEY" &>/dev/null
   
    #TODO: [noman-xg] check specifically against the name of the cluster instead of tailing.
    # Get status of Vizier.
    vizierStatus=$(px get viziers -o json | jq -c '. | select(.ClusterName == "${CLUSTER_NAME}") | .Status')
    
    # check if Vizier is in healthy state or not.
    if [ "$vizierStatus" -ne 1 ]; then
        log_test "${RED}[FAILED]" "[TEST]" "Pixie Vizier is not in healthy state.${CC}"
    else
        log_test "${GREEN}[PASSED]" "[TEST]" "Pixie Vizier is in healthy state.${CC}"
    
    fi
}

# This function creates a test pod in the test namespace and then queries for the test pod using Pixie binary pxl script.  
# The result of the query returns true/false which determines whether Pixie is functional inside the cluster or not.
px_demo_action() {

    log_test "${CYAN}[INFO]" "[TEST]" "Pixie Demo Action. ${CC}"
    podName="$PX_TEST_NS/$TEST_POD"

    #check whether the test namespace exists already or not
    if ! kubectl get namespace "$PX_TEST_NS" &>/dev/null; then
        # Create a namespace for testing.
        kubectl create namespace "$PX_TEST_NS" &>/dev/null
    fi
    
    #check whether the test-pod in test namespace exists or not
    if ! kubectl get pod "$podName" -n "$PX_TEST_NS" &>/dev/null; then
        # Create a pod in the test namespace
        kubectl create -f /src/manifests/test-pod.yaml &>/dev/null
    fi

    #import kubeconfig -- dependancy to run px run command.
    aws eks update-kubeconfig --region ap-southeast-1 --name xgrid-website-migration &>/dev/null

    # Execute a Pxl script to get pods info in a certain namespace. If it returns true, it means Pixie is successfully deployed and actively monitoring the cluster.
    podFound=$(px run px/pods -o json -- --namespace "$PX_TEST_NS"  | jq --arg pod_name "$podName" 'select(._tableName_ == "Pods List") and select(.pod == $podName)')    

    if [[ $podFound == "true" ]]; then

        log_test "${GREEN}[PASSED]" "[TEST]" "Successfully queried for test pod using Pixie. ${CC}"
    else
        log_test "${RED}[FAILED]" "[TEST]" "Could not query for test pod using Pixie. ${CC}"    
    
    fi

    #clean up 
    rm -rf root/.kube/config &>/dev/null
    kubectl delete namespace "$PX_TEST_NS" &>/dev/null
}

print_prompt
# An array of Pixie namespaces is passed to the function. 
pod_status_verifier "${PX_NAMESPACES[@]}"
check_vizier
px_demo_action
