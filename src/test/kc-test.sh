#!/bin/bash

source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/kc-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Kubecost.${CC}"

}
# pod_status_verifier kubecost

check_kubectl_cost() {

    # Check if kubectl_cost is installed
    if command -v kubectl cost &>/dev/null; then
        echo "kubectl cost is already installed. Using it to get cost"
    else
        echo "Installing kubectl cost now"
        install_kubectl_cost
    fi

    kubectl cost namespace --show-all-resources

}
install_kubectl_cost() {
    os=$(uname | tr '[:upper:]' '[:lower:]') &&
        arch=$(uname -m | tr '[:upper:]' '[:lower:]' | sed -e s/x86_64/amd64/) &&
        curl -s -L https://github.com/kubecost/kubectl-cost/releases/latest/download/kubectl-cost-$os-$arch.tar.gz | tar xz -C /tmp &&
        chmod +x /tmp/kubectl-cost &&
        cp /tmp/kubectl-cost /usr/local/bin/kubectl-cost
}
print_prompt
# Kubecost namespace is passed to the function.
pod_status_verifier "$KC_NAMESPACE"
check_kubectl_cost
