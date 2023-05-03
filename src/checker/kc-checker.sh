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

source /src/config/kc-config.sh
source /src/commons/common-functions.sh

# Function that starts basic execution of the script
print_prompt() {
    log "${CYAN}[INFO]" "[CHECKER]" "Detecting Kubecost in the Kubernetes cluster.${CC}"
}

# This function checks if kubectl is configured or not.
check_kubectl() {
    # Checking Kubecost In Kubernetes Cluster
    log "${CYAN}[INFO]" "[CHECKER]" "Checking if kubectl is configured.${CC}"

    if command -v kubectl &>/dev/null; then
        log "${GREEN}[INFO]" "[CHECKER]" "kubectl configurations are obtained successfully.${CC}"
        kubectl_kc_checker # Function call to below defined function.
    else
        log "${RED}[ERROR]" "[CHECKER]" "kubectl is not configured. Using Curl Instead.${CC}"
        curl_kc_checker # Function call to below defined functions.
    fi
}

# This function calls three functions which checks namespace, deployment and image of kubecost using kubectl utility.
kubectl_kc_checker() {
    log "${CYAN}[INFO]" "[CHECKER]" "Checking if kubecost namespace is found in the cluster.${CC}"
    kubectl_kc_ns_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking if kubecost deployment is found in the cluster.${CC}"
    kubectl_kc_deployment_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking correctness of kubecost deployment image.${CC}"
    kubectl_kc_image_checker
}

# Function finds namespace that we are looking for using kubectl tool.
kubectl_kc_ns_checker() {
    returnedNamespace=$(kubectl get ns --no-headers 2>&1 | grep -i kubecost | awk '{print $1}')

    if [ "$returnedNamespace" == "${KC_NAMESPACE[0]}" ]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Namespace $returnedNamespace found in the cluster.${CC}"
    else
        log "${RED}[ERROR]" "[CHECKER]" "Namespace kubecost not found in the cluster.${CC}"
        exit 0
    fi
}

# This function checks whether kubecost deployment is present in the cluster or not.
kubectl_kc_deployment_checker() {
    kubecostDeploy=$(kubectl -n "${KC_NAMESPACE[@]}" get deploy --no-headers 2>&1 | grep -i kubecost-cost-analyzer | awk '{print $1}')
    if [ "$kubecostDeploy" == "${EXPECTED_KC_DEPLOY}" ]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Kubecost deployment found in cluster.${CC}"
    else
        log "${RED}[ERROR]" "[CHECKER]" "Unable to find kubecost Deployment in cluster.${CC}"
        exit 0
    fi
}

# This function checks whether image used by kubecost deployment is correct or not.
kubectl_kc_image_checker() {
    kubecostImage=("$(kubectl -n "${KC_NAMESPACE[@]}" get deployment kubecost-cost-analyzer -o=jsonpath='{$.spec.template.spec.containers[:1].image}')")
    image="${kubecostImage:0:27}"
    if [[ $image == "${KC_IMAGE}" ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Image[$image] found in Deployment [$EXPECTED_KC_DEPLOY] ${GREEN}is correct.${CC}"
        exit 1
    else
        log "${RED}[ERROR]" "[CHECKER]" "Unable to find required image in Deployment${GREEN}[$EXPECTED_KC_DEPLOY].${CC}"
        exit 0
    fi
}

# In the absence of kubectl this function will be called and curl will be used to achieved required checks.
curl_kc_checker() {
    # CURLING API-SERVER. (Getting deployment list and filtering using field selector)
    # Using the pod's environment variables, default serviceaccount's certificate, and default serviceaccount's token to access the cluster.
    deploymentsList=$(curl --silent "$KUBERNETES_API_SERVER_URL"/apis/apps/v1/deployments \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}")

    # Extracting Name and Image from Kubecost Deployment.
    kcDeployment=$(echo "$deploymentsList" | grep -o '"name": "[^"]*' | head -n1)
    kcDeployImage=$(echo "$deploymentsList" | grep -o '"image": "[^"]*')

    # Checking the correctness of name in Kubecost Deployment.
    if [[ $kcDeployment == *"$KC_DEPLOYMENT"* ]]; then

        # Checking the correctness of image in Kubecost Deployment.
        if ! [[ $kcDeployImage == *"$KC_IMAGE"* ]]; then
            log "${RED}[ERROR]" "[CHECKER]" "Kubecost not found.${CC}"
            exit 0
        fi
    else
        log "${RED}[ERROR]" "[CHECKER]" "Kubecost not found.${CC}"
        exit 0
    fi

    log "${GREEN}[INFO]" "[CHECKER]" "Kubecost Exists In Your Cluster.${CC}"
    exit 1
}

# Calling the above Defined functions.
print_prompt
check_permissions
check_kubectl
