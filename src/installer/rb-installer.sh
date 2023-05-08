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

# This script installs Robusta in a Kubernetes cluster using Helm.

# Import configuration variables and common functions.
source /src/config/rb-config.sh
source /src/commons/common-functions.sh

# Print a prompt to the user.
print_prompt() {


    log "${CYAN}[INFO]" "[INSTALLER]" "Initiating installation of Robusta in your cluster.${CC}"
}

# Install Robusta using Helm.
rb_installer() {

    # This function installs Robusta using Helm.

    # Installing Robusta using Helm
    if ! helm repo add robusta https://robusta-charts.storage.googleapis.com &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to add Robusta Helm repository. Exiting.${CC}"
        exit 1
    fi

    if ! helm repo update &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to update Robusta Helm repository. Exiting.${CC}"
        exit 1
    fi

    if ! helm install robusta robusta/robusta -f "$PREFLIGHT_DIR_PATH/generated_values.yaml" -n robusta --create-namespace &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to install Robusta using Helm. Exiting.${CC}"
        exit 1
    fi

    # Waiting for Robusta deployments to become available
    if ! kubectl -n robusta wait deployment robusta-runner robusta-forwarder --for=condition=Available --timeout=1h &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to wait for Robusta deployments to become available. Exiting.${CC}"
        exit 1
    fi

    # Watching runner logs
    watch_runner_logs

}

#Load robusta custom remediation actions
load_playbook_actions() {

    # This function loads the playbook actions.

    log "${CYAN}[INFO]" "[INSTALLER]" "Loading playbook actions.${CC}"

    # Pushing our playbook action
    if ! robusta playbooks push "$PLAYBOOK_DIR_PATH" --namespace="${RB_NAMESPACE[0]}" >/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to load playbook actions. Exiting.${CC}"
        exit 1
    fi

    log "${CYAN}[INFO]" "[INSTALLER]" "Playbook actions loaded.${CC}"
    exit 0
}

watch_runner_logs() {

    # This function watches logs of robusta-runner and checks if all the actions are loaded.
    # TODO: Add timeout if actions aren't loaded.

    if ! kubectl -n robusta logs -f -l app=robusta-runner | while read -r line; do
        echo "$line" | grep -E ".*Serving Flask app 'robusta.runner.web'.*" &>/dev/null
        result=$?
        if [ $result -eq 0 ]; then
            pkill -f "kubectl -n robusta logs -f -l app=robusta-runner"
            break
        fi
    done; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to watch runner logs. Exiting.${CC}"
        exit 1
    fi

}

# Run the script.
print_prompt
rb_installer
load_playbook_actions
