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
    _=$(curl -O https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz > /dev/null)
    _=$(tar -zxvf helm-v3.10.0-linux-amd64.tar.gz > /dev/null )
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

# The wrapper_function ensures that the deployment and pods in a namespace are fully operational by waiting for them to be in a running state.
wait_for_deployment() {
  while true; do
    dc=$(kubectl get deployments -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1 | wc -w)

    # Check to see if atleast one deployment can be found in the namespace.
    if [ "$dc" -gt 0 ]; then
      pods=$(kubectl get pods -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1)
      for pod in $pods; do
        while true; do
          status=$(kubectl get pods "$pod" -n "$1" -o jsonpath='{.status.phase}')

          # Check if Pods Phase reached running or succeeded.
          if [[ $status == "Succeeded" || $status == "Running" ]]; then
            log "Pod $pod reached the desired status: $status" 1> /dev/null
            break
          else
            log "Waiting for pod $pod to reach the desired status: $status" 1> /dev/null
          fi
        done
      done
      break
    else
      log "Waiting for Pixie deployments to become available." 1> /dev/null
    fi
done
}

