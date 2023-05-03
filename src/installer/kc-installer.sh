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
    kubecostDeploy=$(kubectl -n "${KC_NAMESPACE[@]}" get deploy --no-headers 2>&1 | grep -i "${EXPECTED_KC_DEPLOY}" | awk '{print $1}')
    if [ "$kubecostDeploy" == "${EXPECTED_KC_DEPLOY}" ]; then
        log "${GREEN}[INFO]" "[INSTALLER]" "Kubecost ${GREEN}already found in the cluster.${CC}"
        exit 0
    else
        log "${RED}[ERROR]" "[INSTALLER]" "Unable to find kubecost Deployment in cluster. Installing kubecost now...${CC}"

        # It creates a namespace called kubecost, Adds repo in helm and installs kubecost
        _=$(
            helm repo add kubecost https://kubecost.github.io/cost-analyzer/
            helm install kubecost kubecost/cost-analyzer -n "${KC_NAMESPACE[@]}" --create-namespace 2>&1
        )

        # Wait till kubecost prometheus-server pod is ready.
        _=$(kubectl -n "${KC_NAMESPACE[@]}" wait pod --for=condition=Ready -l component=server --timeout=1h)
        create_kc_service
    fi
}

create_kc_service() {

    kubectl -n "${KC_NAMESPACE[@]}" expose deployment "${EXPECTED_KC_DEPLOY}" --port=80 --target-port=9090 --name=kubecost-ui-service --type=LoadBalancer &>/dev/null
}

# Calling functions defined above
kc_installer
