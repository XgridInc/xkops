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


source /src/config/rb-config.sh
source /src/commons/common-functions.sh

print_prompt() {
    log "${CYAN}[INFO]" "[CHECKER]" "Initiating checks if Robusta installed in your cluster."

}

#Ensure cluster has kubectl installed, otherwise use curl
check_kubectl() {

    if ! command -v kubectl &>/dev/null; then
        log "${CYAN}[INFO]" "[CHECKER]" "kubectl not found. Checking through curl.${CC}"
        curl_rb_checker

    else
        log "${CYAN}[INFO]" "[CHECKER]" "kubectl found. Checking through kubectl.${CC}"
        kubectl_rb_checker

    fi

}

kubectl_rb_checker() {
    # Set the list of deployment names and image names to check
    deployment_names=("${EXPECTED_RUNNER_NAME}" "${EXPECTED_FORWARDER_NAME}")
    image_names=("${EXPECTED_RUNNER_IMAGE}" "${EXPECTED_FORWARDER_IMAGE}")

    # Get the number of deployments
    num_deployments=${#deployment_names[@]}

    # Set a flag to indicate whether the deployment and image were found
    found=0

    # Get a list of all namespaces
    # namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')
    mapfile -t namespaces < <(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

    # Iterate through each namespace
    for namespace in "${namespaces[@]}"; do
        # Get a list of all deployments in the namespace
        deployments=$(kubectl get deployments -n "$namespace" -o jsonpath='{.items[*].metadata.name}')

        # Iterate through each deployment
        for deployment in $deployments; do
            # Iterate through each specified deployment name and image name
            for i in $(seq 0 $((num_deployments - 1))); do
                # Check if the deployment matches the specified deployment name
                if [ "$deployment" == "${deployment_names[$i]}" ]; then
                    # Get the image for the deployment
                    deployment_image=$(kubectl get deployment "$deployment" -n "$namespace" -o jsonpath='{.spec.template.spec.containers[0].image}')

                    # Check if the image matches the specified image name
                    if [ "$deployment_image" == "${image_names[$i]}" ]; then
                        # Get the status of the pods in the deployment
                        pod_status=$(kubectl get pods -n "$namespace" -l "app=$deployment" -o jsonpath='{.items[*].status.phase}')

                        # Check if any of the pods are not in the "Running" state
                        if [[ "$pod_status" != *"Running"* ]]; then
                            # Print an error message
                            log "${RED}[ERROR]" "[CHECKER]" "Deployment $deployment in namespace $namespace is not running.${CC}"
                            # Set the flag to indicate that the deployment and image were found
                            found=0
                        else

                            # Set the flag to indicate that the deployment and image were found
                            found=1
                        fi
                    else
                        # Print an error message
                        log "${RED}[ERROR]" "[CHECKER]" "Incorrect image in {$deployment} deployment in namespace $namespace.${CC}"

                    fi
                fi
            done
        done
    done

    # Check if the flag is still set to 0
    if [ "$found" -eq 0 ]; then
        # Print an error message
        log "${RED}[ERROR]" "[CHECKER]" "Robusta not found.${CC}"
    else
        # Print a success message
        log "${GREEN}[INFO]" "[CHECKER]" "Robusta Exists in your cluster${CC}."
        exit 1
    fi

}

curl_rb_checker() {

    # Get a list of all namespaces in the cluster
    mapfile -t namespaces < <(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces")

    runner_found=false
    forwarder_found=false

    # Extract the names of the namespaces from the JSON response
    mapfile -t namespaces < <(echo "${namespaces[@]}" | sed -n 's/.*"name": "\(.*\)",.*/\1/p')

    # Iterate through the namespaces
    for ns in "${namespaces[@]}"; do
        # Check if the "robusta-runner" deployment exists in the namespace
        runner=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/apis/apps/v1/namespaces/$ns/deployments/$EXPECTED_RUNNER_NAME")
        if [ "$runner" != "Not Found" ]; then
            # Extract the image for the "robusta-runner" deployment from the JSON response
            runner_image=$(echo "$runner" | sed -n 's/.*"image": "\(.*\)",.*/\1/p')
            if [ "$runner_image" == "${EXPECTED_RUNNER_IMAGE}" ]; then

                # Get the list of pods for the "robusta-runner" deployment
                pods=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces/$ns/pods?labelSelector=app%3Drobusta-runner")

                # Iterate through the pods
                while read -r pod; do
                    # Extract the status of the pod from the JSON response
                    status=$(echo "$pod" | grep '"phase": "Running"')
                    if [ -n "$status" ]; then
                        runner_found=true
                    fi
                done <<<"$pods"
            fi
        fi
        # Check if the "robusta-forwarder" deployment exists in the namespace
        forwarder=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" "$KUBERNETES_API_SERVER_URL/apis/apps/v1/namespaces/$ns/deployments/$EXPECTED_FORWARDER_NAME")
        if [ "$forwarder" != "Not Found" ]; then
            # Extract the image for the "robusta-forwarder" deployment from the JSON response
            forwarder_image=$(echo "$forwarder" | sed -n 's/.*"image": "\(.*\)",.*/\1/p')
            if [ "$forwarder_image" == "${EXPECTED_FORWARDER_IMAGE}" ]; then

                # Get the list of pods for the "robusta-forwarder" deployment
                pods=$(curl -s -k --cacert "$CA_CERT_PATH" -H "${HEADERS[@]}" -H "Content-Type: application/json" "$KUBERNETES_API_SERVER_URL/api/v1/namespaces/$ns/pods?labelSelector=app%3Drobusta-forwarder")

                # Iterate through the pods
                while read -r pod; do
                    # Extract the status of the pod from the JSON response
                    status=$(echo "$pod" | grep '"phase": "Running"')
                    if [ -n "$status" ]; then
                        forwarder_found=true

                    fi
                done <<<"$pods"
            fi
        fi
    done

    if [[ "$runner_found" == true ]] && [[ "$forwarder_found" == true ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Robusta Exists in your cluster.${CC}"
        exit 1
    else
        log "${RED}[ERROR]" "[CHECKER]" "Robusta not found.${CC}"
    fi
}

print_prompt
check_permissions
check_kubectl
exit 0
