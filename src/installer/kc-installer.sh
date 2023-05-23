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

# Installer function for Kubecost
kc_installer() {

    # This function checks if Kubecost is already installed in the cluster. If it is not installed, it installs Kubecost.

    kubecostDeploy=$(kubectl -n "${KC_NAMESPACE[@]}" get deploy --no-headers 2>&1 | grep -i "${EXPECTED_KC_DEPLOY}" | awk '{print $1}')

    if [ "$kubecostDeploy" == "${EXPECTED_KC_DEPLOY}" ]; then
        log "${GREEN}[INFO]" "[INSTALLER]" "Kubecost already found in the cluster.${CC}"
        exit 0
    else
        log "${RED}[ERROR]" "[INSTALLER]" "Unable to find Kubecost Deployment in the cluster. Installing Kubecost now...${CC}"

        # Add Kubecost Helm repository and install Kubecost
        if ! helm repo add kubecost https://kubecost.github.io/cost-analyzer/ &>/dev/null; then
            log "${RED}[ERROR]" "[INSTALLER]" "Failed to add Kubecost Helm repository. Exiting.${CC}"
            exit 1
        fi

        if ! helm install kubecost kubecost/cost-analyzer -n "${KC_NAMESPACE[@]}" --create-namespace &>/dev/null; then
            log "${RED}[ERROR]" "[INSTALLER]" "Failed to install Kubecost. Exiting.${CC}"
            exit 1
        fi

        # Wait for Kubecost Prometheus server and cost analyzer pod to be ready
        if ! kubectl -n "${KC_NAMESPACE[@]}" wait pod --for=condition=Ready -l component=server -l app=cost-analyzer --timeout=1h &>/dev/null; then
            log "${RED}[ERROR]" "[INSTALLER]" "Failed to wait for Kubecost pods to be ready. Exiting.${CC}"
            exit 1
        fi

        create_kc_service
    fi
}
create_kc_service() {

    # This function creates a service for Kubecost UI.

    if ! kubectl -n "${KC_NAMESPACE[@]}" expose deployment "${EXPECTED_KC_DEPLOY}" --port=80 --target-port=9090 --name="${KC_UI_SVC}" --type=LoadBalancer &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to create Kubecost UI service. Exiting.${CC}"
        exit 1
    else
        log "${GREEN}[INFO]" "[INSTALLER]" "Kubecost UI service created successfully.${CC}"
    fi

}
# Calling functions defined above
kc_installer
