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

  # Installing Robusta using helm
  helm repo add robusta https://robusta-charts.storage.googleapis.com &>/dev/null && helm repo update &>/dev/null
  helm install robusta robusta/robusta -f "$PREFLIGHT_DIR_PATH/generated_values.yaml" -n robusta --create-namespace &>/dev/null
  kubectl -n robusta wait deployment robusta-runner robusta-forwarder --for=condition=Available --timeout=1h &>/dev/null
  watch_runner_logs
  log "${GREEN}[INFO]" "[INSTALLER]" "Robusta successfully installed.${CC}"
}

#Load robusta custom remediation actions
load_playbook_actions() {

    log "${CYAN}[INFO]" "[INSTALLER]" "Loading playbook actions.${CC}"
    
    #pushing our playbook action
    robusta playbooks push "$PLAYBOOK_DIR_PATH" --namespace=robusta >/dev/null
    log "${CYAN}[INFO]" "[INSTALLER]" "Playbook actions loaded.${CC}"
    exit 0
}

watch_runner_logs() {

    #This functions watches logs of robusta-runner and checks if all the actions are loaded
    #TODO: Add timeout if actions aren't loaded
    
    kubectl -n robusta logs -f -l app=robusta-runner | while read -r line; do
        echo "$line" | grep -E ".*Serving Flask app 'robusta.runner.web'.*" &>/dev/null
        result=$?
        if [ $result -eq 0 ]; then
            pkill -f "kubectl -n robusta logs -f -l app=robusta-runner"
            break
        fi
    done

}

# Run the script.
print_prompt
rb_installer
load_playbook_actions
