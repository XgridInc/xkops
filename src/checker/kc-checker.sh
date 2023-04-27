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
    kubectl_kcNS_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking if kubecost deployment is found in the cluster.${CC}"
    kubectl_kcDeploy_checker

    log "${CYAN}[INFO]" "[CHECKER]" "Checking correctness of kubecost deployment image.${CC}"
    kubectl_kcImage_checker
}

# Function finds kubecost namespace that we are looking for using kubectl tool.
kubectl_kcNS_checker() {
    returnedNamespace=$(kubectl -n kubecost get ns --no-headers 2>&1)

    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for kubecost namespace.${CC}"
        exit 1 # Exit with a non-zero code to indicate failure.
    fi

    returnedNamespace=$(echo "$returnedNamespace" | grep -i kubecost | awk '{print $1}')

    if [ "$returnedNamespace" == "kubecost" ]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Namespace $returnedNamespace found in the cluster.${CC}"
    else
        log "${RED}[ERROR]" "[CHECKER]" "Namespace kubecost not found in the cluster.${CC}"
        exit 0
    fi
}

# This function checks whether kubecost deployment is present in the cluster or not.
kubectl_kcDeploy_checker() {
    kubecostDeploy=$(kubectl -n kubecost get deploy --no-headers 2>&1 | grep -i kubecost-cost-analyzer | awk '{print $1}')
    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for kubecost deployment.${CC}"
        exit 1 # Exit the script with a non-zero code to indicate failure.
    fi

    if [ "$kubecostDeploy" == "kubecost-cost-analyzer" ]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Kubecost deployment found in cluster.${CC}"
    else
        log "${RED}[ERROR]" "[CHECKER]" "Unable to find kubecost Deployment in cluster.${CC}"
        exit 0
    fi
}

# This function checks whether image used by kubecost deployment is correct or not.
kubectl_kcImage_checker() {
    kubecostImage=("$(kubectl -n kubecost get deployment kubecost-cost-analyzer -o=jsonpath='{$.spec.template.spec.containers[:1].image}')")
    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while checking for kubecost image.${CC}"
        exit 1 # Exit the script with a non-zero code to indicate failure.
    fi
    
    image="${kubecostImage:0:27}"
    deployment="kubecost-cost-analyzer"
    if [[ $image == "gcr.io/kubecost1/cost-model" ]]; then
        log "${GREEN}[INFO]" "[CHECKER]" "Image[$image] found in Deployment [$deployment] ${GREEN}is correct.${CC}"
        exit 1
    else
        log "${RED}[ERROR]" "[CHECKER]" "Unable to find required image in Deployment${GREEN}[$deployment].${CC}"
        exit 0
    fi
}

# In the absence of kubectl this function will be called and curl will be used to achieved required checks.
curl_kc_checker() {
    # CURLING API-SERVER. (Getting deployment list and filtering using field selector)
    # Using the pod's environment variables, default serviceaccount's certificate, and default serviceaccount's token to access the cluster.
    kc_deploy=$(curl --silent "$KUBERNETES_API_SERVER_URL"/apis/apps/v1/deployments \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}")
    # Check the exit code of the last command (kubectl).
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Error occurred while curling the Kubernetes API server.${CC}"
        exit 1 # Exit the script with a non-zero code to indicate failure.
    fi

    # Extracting Name and Image from Kubecost Deployment.
    kc_deploy_name=$(echo "$kc_deploy" | grep -o '"name": "[^"]*' | head -n1)
    kc_deploy_image=$(echo "$kc_deploy" | grep -o '"image": "[^"]*')

    # Checking the correctness of name in Kubecost Deployment.
    if [[ $kc_deploy_name == *"$KC_DEPLOYMENT"* ]]; then

        # Checking the correctness of image in Kubecost Deployment.
        if ! [[ $kc_deploy_image == *"$KC_IMAGE"* ]]; then
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
