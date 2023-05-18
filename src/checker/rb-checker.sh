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

# Skip this check
# shellcheck source=/dev/null
source /src/config/rb-config.sh
source /src/commons/common-functions.sh

# Function that starts basic execution of the checker script
print_prompt() {
    log "${CYAN}[INFO]" "[CHECKER]" "Detecting robusta in the Kubernetes cluster.${CC}"
}

# This function checks if kubectl is configured or not.
check_kubectl() {
    # Checking robusta In Kubernetes Cluster
    log "${CYAN}[INFO]" "[CHECKER]" "Checking if kubectl is configured.${CC}"

    if command -v kubectl &>/dev/null; then
        log "${GREEN}[INFO]" "[CHECKER]" "kubectl configurations are obtained successfully.${CC}"
        kubectl_rb_checker # Function call to below defined function.
    else
        log "${RED}[ERROR]" "[CHECKER]" "kubectl is not configured. Using Curl Instead.${CC}"
        curl_rb_checker # Function call to below defined functions.
    fi
}

# This function calls three functions which checks namespace, deployment and image of robusta using kubectl utility.
kubectl_rb_checker() {
    log "${CYAN}[INFO]" "[CHECKER]" "Checking if robusta namespace is found in the cluster.${CC}"
    kubectl_rb_ns_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking if robusta deployment is found in the cluster.${CC}"
    kubectl_rb_deployment_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking correctness of robusta deployment image.${CC}"
    kubectl_rb_image_checker
}

# Function finds robusta namespace that we are looking for using kubectl tool.
kubectl_rb_ns_checker() {
    returnedNamespace=$(kubectl get ns --no-headers 2>&1)

    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for robusta namespace.${CC}"
        exit 1 # Exit with a non-zero code to indicate failure.
    fi

    returnedNamespace=$(echo "$returnedNamespace" | grep -i robusta | awk '{print $1}')

    if [ "$returnedNamespace" == "${RB_NAMESPACE[0]}" ]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Namespace $returnedNamespace found in the cluster.${CC}"
    else
        log "${RED}[INFO]" "[CHECKER]" "Namespace robusta not found in the cluster.${CC}"
        exit 0
    fi
}

# This function checks whether robusta deployment is present in the cluster or not.
kubectl_rb_deployment_checker() {
    runnerDeploy=$(kubectl -n "${RB_NAMESPACE[@]}" get deploy --no-headers 2>&1 | grep -i "${EXPECTED_RUNNER_NAME}" | awk '{print $1}')
    forwarderDeploy=$(kubectl -n "${RB_NAMESPACE[@]}" get deploy --no-headers 2>&1 | grep -i "${EXPECTED_FORWARDER_NAME}" | awk '{print $1}')
    
    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for robusta deployment.${CC}"
        exit 1 # Exit the script with a non-zero code to indicate failure.
    fi

    if [[ "$runnerDeploy" == "${EXPECTED_RUNNER_NAME}" && "$forwarderDeploy" == "${EXPECTED_FORWARDER_NAME}" ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "robusta deployment found in cluster.${CC}"
    else
        log "${RED}[INFO]" "[CHECKER]" "Unable to find robusta Deployment in cluster.${CC}"
        exit 0
    fi
}

# This function checks whether image used by robusta deployment is correct or not.
kubectl_rb_image_checker() {
    runnerImage=("$(kubectl -n "${RB_NAMESPACE[@]}" get deployment "${EXPECTED_RUNNER_NAME}" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')")
    forwarderImage=("$(kubectl -n "${RB_NAMESPACE[@]}" get deployment "${EXPECTED_FORWARDER_NAME}" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')")
    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for robusta image.${CC}"
        exit 1 # Exit the script with a non-zero code to indicate failure.
    fi

    if [[ "${runnerImage[0]}" == "${EXPECTED_RUNNER_IMAGE}" && "${forwarderImage[0]}" == "${EXPECTED_FORWARDER_IMAGE}" ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Images found in Deployments ${GREEN}are correct.${CC}"
        exit 1
    else
        log "${RED}[ERROR]" "[CHECKER]" "Unable to find required image in Deployment${GREEN}.${CC}"
        exit 0
    fi
}

curl_rb_checker() {

    # Get a list of all namespaces in the cluster
    mapfile -t namespaces < <(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces")

    runnerFound=false
    forwarderFound=false

    # Extract the names of the namespaces from the JSON response
    mapfile -t namespaces < <(echo "${namespaces[@]}" | sed -n 's/.*"name": "\(.*\)",.*/\1/p')

    # Iterate through the namespaces
    for ns in "${namespaces[@]}"; do
        # Check if the "robusta-runner" deployment exists in the namespace
        runner=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/apis/apps/v1/namespaces/$ns/deployments/$EXPECTED_RUNNER_NAME")
        if [ "$runner" != "Not Found" ]; then
            # Extract the image for the "robusta-runner" deployment from the JSON response
            runnerImage[0]=$(echo "$runner" | sed -n 's/.*"image": "\(.*\)",.*/\1/p')
            if [ "${runnerImage[0]}" == "${EXPECTED_RUNNER_IMAGE}" ]; then

                # Get the list of pods for the "robusta-runner" deployment
                pods=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces/$ns/pods?labelSelector=app%3Drobusta-runner")

                # Iterate through the pods
                while read -r pod; do
                    # Extract the status of the pod from the JSON response
                    status=$(echo "$pod" | grep '"phase": "Running"')
                    if [ -n "$status" ]; then
                        runnerFound=true
                    fi
                done <<<"$pods"
            fi
        fi
        # Check if the "robusta-forwarder" deployment exists in the namespace
        forwarder=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/apis/apps/v1/namespaces/$ns/deployments/$EXPECTED_FORWARDER_NAME")
        if [ "$forwarder" != "Not Found" ]; then
            # Extract the image for the "robusta-forwarder" deployment from the JSON response
            forwarderImage[0]=$(echo "$forwarder" | sed -n 's/.*"image": "\(.*\)",.*/\1/p')
            if [ "${forwarderImage[0]}" == "${EXPECTED_FORWARDER_IMAGE}" ]; then

                # Get the list of pods for the "robusta-forwarder" deployment
                pods=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" -H "Content-Type: application/json" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces/$ns/pods?labelSelector=app%3Drobusta-forwarder")

                # Iterate through the pods
                while read -r pod; do
                    # Extract the status of the pod from the JSON response
                    status=$(echo "$pod" | grep '"phase": "Running"')
                    if [ -n "$status" ]; then
                        forwarderFound=true

                    fi
                done <<<"$pods"
            fi
        fi
    done

    if [[ "$runnerFound" == true ]] && [[ "$forwarderFound" == true ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Robusta Exists in your cluster.${CC}"
        exit 1
    else
        log "${RED}[ERROR]" "[CHECKER]" "Robusta not found.${CC}"
    fi
}

# Calling the above Defined functions.
print_prompt
check_permissions
check_kubectl
