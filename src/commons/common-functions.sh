#!/bin/bash

# logging function for checker
log() {
    local level=$1
    local function=$2
    local message=$3
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $level $function $message" | tee -a /tmp/app.log
}

log_test() {
    local level=$1
    local function=$2
    local message=$3
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $level $function $message" | tee -a /tmp/app_test.log
}

# Function to check if helm is installed in the cluster
helm_checker() {

    log "${YELLOW}[INFO]" "[PRE-FLIGHT]" "Checking if helm is configured.${CC}"
    if command -v helm &>/dev/null; then
        log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Helm configurations are obtained successfully.${CC}"
        exit 0
    else
        log "${BOLD_RED}[ERROR]" "[PRE-FLIGHT]" "Helm is not installed. Installing it now.${CC}"
        helm_installer # Function call to install helm
    fi
}

# Function to install helm
helm_installer() {
    # Downloads helm 3 binary and installs.
    _=$(curl -O https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz >/dev/null)
    _=$(tar -zxvf helm-v3.10.0-linux-amd64.tar.gz >/dev/null)
    _=$(cp ./linux-amd64/helm /usr/local/bin/)
    if command -v helm &>/dev/null; then
        log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Helm has been installed successfully.${CC}"
    else
        log "${BOLD_RED}[ERROR]" "[PRE-FLIGHT]" "Helm is not installed. Exiting...${CC}"
        exit 1
    fi
}

# Checking if service account has permission to list deployments
# If the service account ha no permisions then the script will terminate.
check_permissions() {
    # Define constant for "Forbidden" error message
    FORBIDDEN_ERROR_MESSAGE="Forbidden"

    deploy_permission=$(curl --silent "$KUBERNETES_API_SERVER_URL/apis/apps/v1/deployments" \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}")

    # Extract the "reason" field from the response
    reason=$(echo "$deploy_permission" | grep -o '"reason": "[^"]*')

    # Check if the "reason" field contains the word "Forbidden"
    if [[ $reason == *"$FORBIDDEN_ERROR_MESSAGE"* ]]; then
        log "${BOLD_RED}[ERROR]" "[CHECKER]" "Forbidden, cannot list deployments. Exiting${CC}"
        log "${YELLOW}[INFO]" "[CHECKER]" "Create clusterrole and clusterrole binding with enough permissions ${CC}"
        exit 1
    fi
}

# this function will check the status of each pod in a specific
# namespace whether it is in running or completed state.
pod_status_verifier() {
    # get a list of namespaces and iterate over those namespaces4
    # to check the status of each pod in a namespace.
    namespaces=("${@}")
    for namespace in "${namespaces[@]}"; do
    
        # Get a list of pods in the namespace
        pods=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}')

        # Iterate over pods in the namespace to verify their status
        for pod in $pods; do
            pod_status=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.phase}')

            # If pod status is not Running or Completed, tool is not deployed successfully.
            if [[ "$pod_status" != "Running" && "$pod_status" != "Succeeded" ]]; then

                log "${RED}[ERROR]" "[TEST]" "$pod pod in  $namespace namespace is not in Running state${CC}"
            else
                log "${GREEN}[PASSED]" "[TEST]" "$pod pod in $namespace namespace is in Running state${CC}"
            fi
        done
    done
}

# this function will get the eks cluster name that will be used
# in tool instalation using helm.
get_eks_cluster_name() {

    # Get the current context of the kubeconfig
    current_context=$(kubectl config current-context)

    # Get the cluster name associated with the current context
    cluster_name=$(kubectl config get-contexts "$current_context" | awk '{print $3}' | grep -Eo 'arn:aws:eks:[a-zA-Z0-9-]*:[0-9]*:[cluster/[a-zA-Z0-9-]*|@[a-zA-Z0-9-]*')
    export cluster_name
    rm -rf root/.kube/config
    # Print the cluster name
    return "$cluster_name"
}
