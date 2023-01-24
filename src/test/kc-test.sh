#!/bin/bash

source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/kc-config.sh

print_prompt() {
    log_test "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Kubecost.${CC}"

}

# This Function checks whether kubectl_cost plugin is installed or not
# This plugin is used to get cost data from the cluster.
check_kubectl_cost_plugin() {

    # Check if kubectl_cost plugin is installed
    if command -v kubectl-cost &>/dev/null; then
        log_test "${GREEN}[PASSED]" "[TEST]" "kubectl cost plugin is already installed.${CC}"
    else
        log_test "${RED}[FAILED]" "[TEST]" "Installing kubectl cost plugin now.${CC}"
        install_kubectl_cost
    fi
    # Checks if kubectl_cost plugin can retrieve cost data using kubecost-cost-analyzer service.
    get_cost

}

# Function to print UI links for all three tools to access their respective dashboards
print_UI_links() {
    log_test "${CYAN}[INFO]" "[TEST]" "Robusta UI: ${BOLD_GREEN}https://platform.robusta.dev/${CC}"
    log_test "${CYAN}[INFO]" "[TEST]" "Pixie UI: ${BOLD_GREEN}https://work.withpixie.ai/live/clusters/xgrid-website-migration${CC}"
    log_test "${CYAN}[INFO]" "[TEST]" "Kubecost UI:${BOLD_GREEN}http://ad8796567c1cc43559af0064c716c9e0-2077374114.ap-southeast-1.elb.amazonaws.com/${CC}"
}

# This Function uses kubecost-cost-analyzer service to get cost data from the cluster.
# If the data is retrieved successfully, it means kubecost is installed in the cluster and can access cluster resources.
get_cost() {
    if kubectl cost namespace --show-all-resources &>/dev/null; then
        log_test "${GREEN}[PASSED]" "[TEST]" "Kubecost is installed successfully.${CC}"
        print_UI_links
        exit 0
    else
        log_test "${RED}[FAILED]" "[TEST]" "Kubecost is not installed in the cluster.${CC}"
        exit 1
    fi
}

# Function to install kubectl_cost plugin in the cluster
install_kubectl_cost() {
    os=$(uname | tr '[:upper:]' '[:lower:]') &&
        arch=$(uname -m | tr '[:upper:]' '[:lower:]' | sed -e s/x86_64/amd64/) &&
        curl -s -L https://github.com/kubecost/kubectl-cost/releases/latest/download/kubectl-cost-"$os"-"$arch".tar.gz | tar xz -C /tmp &&
        chmod +x /tmp/kubectl-cost &&
        mv /tmp/kubectl-cost /usr/local/bin/kubectl-cost
}

print_prompt
# Kubecost namespace is passed to the function.
pod_status_verifier "$KC_NAMESPACE"
check_kubectl_cost_plugin
