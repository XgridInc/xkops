#!/bin/bash

# This script installs Robusta in a Kubernetes cluster using Helm.

# Import configuration variables and common functions.
source /src/config/rb-config.sh
source /src/commons/common-functions.sh

# Print a prompt to the user.
print_prompt() {
    log "${CYAN}[INFO]" "[INSTALLER]" "Initiating installation of Robusta in your cluster."
}

# Install Robusta using Helm.
rb_installer() {

    #TODO: Set up error handling if helm installation fails
    # Check if Helm is installed.
    if command -v helm &>/dev/null; then
        # If Helm is present, use it to install Robusta.
        helm repo add robusta https://robusta-charts.storage.googleapis.com && helm repo update &>/dev/null
        helm install robusta robusta/robusta -f "$PREFLIGHT_DIR_PATH/generated_values.yaml" -n robusta --create-namespace &>/dev/null
        kubectl -n robusta wait deployment robusta-runner robusta-forwarder --for=condition=Available --timeout=1h
        watch_runner_logs
        log "${GREEN}[INFO]" "[INSTALLER]" "Robusta sucessfully installed.${CC}"
        exit 0

    else
        # If Helm is not installed, print an error message and exit.
        log "${RED}[ERROR]" "[INSTALLER]" "Helm is not installed. Exiting...${CC}"
        log "${YELLOW}[INFO]" "[INSTALLER]" "Install Helm.${CC}"
        exit 1

    fi
}

watch_runner_logs() {

    #This functions watches logs of robusta-runner and checks if all the actions are loaded

    kubectl -n robusta logs -f -l app=robusta-runner | while read line; do
        echo "$line" | grep -E ".*Initializing jobs cache.*" >/dev/null
        result=$?
        if [ $result -eq 0 ]; then
            echo "Initializing jobs cache found in logs"
            pkill -f "kubectl -n robusta logs -f -l app=robusta-runner"
            break
        fi
    done

}

# Run the script.
print_prompt
rb_installer
