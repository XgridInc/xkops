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
source /src/config/kc-config.sh

print_prompt() {
    log_test "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Kubecost.${CC}"

}

# This Function checks whether kubectl_cost plugin is installed or not
# This plugin is used to get cost data from the cluster.
check_kubectl_cost_plugin() {

    # Check if kubectl_cost plugin is installed
    if command -v kubectl-cost &>/dev/null; then
        log_test "${GREEN}[PASSED]" "[TEST]" "kubectl cost plugin already installed.${CC}"
    else
        log_test "${RED}[FAILED]" "[TEST]" "Kubecost cost plugin isn't installed in the cluster.${CC}"
        log_test "${CYAN}[INFO]" "[TEST]" "Installing kubectl cost plugin...${CC}"
        install_kubectl_cost
    fi
    # Checks if kubectl_cost plugin can retrieve cost data using kubecost-cost-analyzer service.
    log_test "${CYAN}[INFO]" "[TEST]" "Verifying kubecost installation using kubectl cost plugin...${CC}"
    get_cost

}

# Function to print UI links for all three tools to access their respective dashboards
#TODO: To be removed from here.
print_UI_links() {
    log_test "${CYAN}[INFO]" "[TEST]" "Robusta UI: ${GREEN}https://platform.robusta.dev/${CC}"
    log_test "${CYAN}[INFO]" "[TEST]" "Pixie UI: ${GREEN}https://work.withpixie.ai/live/clusters/xgrid-website-migration${CC}"
    KC_LOADBALANCER=$(kubectl get svc kubecost-ui-service -n "${KC_NAMESPACE[@]}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    log_test "${CYAN}[INFO]" "[TEST]" "Kubecost UI:${GREEN} $KC_LOADBALANCER ${CC}"
}

# This Function uses kubecost-cost-analyzer service to get cost data from the cluster.
# If the data is retrieved successfully, it means kubecost is installed in the cluster and can access cluster resources.
get_cost() {

    _=$(kubectl cost namespace --show-all-resources 2>&1)
    if kubectl_exit_code=$? && [ $kubectl_exit_code -eq 0 ]; then
        # Command succeeded it means kubecost is installed successfully
        log_test "${GREEN}[PASSED]" "[TEST]" "Kubecost is installed successfully on your cluster.${CC}"
        print_UI_links
        exit 0
    else
        # command failed which means kubecost is not installed successfully
        log_test "${RED}[FAILED]" "[TEST]" "Kubecost is not installed on your cluster.${CC}"
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
    log_test "${GREEN}[PASSED]" "[TEST]" "kubectl cost plugin installed successfully${CC}"
}

print_prompt
# Kubecost namespace is passed to the function.
pod_status_verifier "${KC_NAMESPACE[@]}"
check_kubectl_cost_plugin
