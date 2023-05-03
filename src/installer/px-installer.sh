#!/usr/bin/env bash

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

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

# Installing pixie on a containerized environment using Helm.
px_installer() {

    # This function installs Pixie on the cluster using Helm.

    # Install Pixie binary on the container
    log "${CYAN}[INFO]" "[INSTALLER]" "Downloading Pixie binary on the container.${CC}"
    if ! echo "y" | bash -c "$(curl -fsSL https://withpixie.ai/install.sh)" &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to download Pixie binary. Exiting.${CC}"
        exit 1
    else
        log "${GREEN}[INFO]" "[INSTALLER]" "Pixie binary downloaded successfully.${CC}"
    fi

    # Deploy Pixie using Helm
    log "${CYAN}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm.${CC}"
    if ! helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to add Pixie Helm repository. Exiting.${CC}"
        exit 1
    fi

    if ! helm repo update &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to update Pixie Helm repository. Exiting.${CC}"
        exit 1
    fi

    if ! helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName=xgrid-website-migration --namespace pl --create-namespace &>/dev/null; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to deploy Pixie using Helm. Exiting.${CC}"
        exit 1
    fi

    # Wait for Pixie deployments to become available
    log "${CYAN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available.${CC}"
    if ! validate_healthy_deployment "$OLMNS"; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to wait for OLM namespace deployment to become available. Exiting.${CC}"
        exit 1
    fi

    if ! validate_healthy_deployment "$PXOPNS"; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to wait for Pixie operator namespace deployment to become available. Exiting.${CC}"
        exit 1
    fi

    if ! validate_healthy_deployment "$PLNS"; then
        log "${RED}[ERROR]" "[INSTALLER]" "Failed to wait for Pixie namespace deployment to become available. Exiting.${CC}"
        exit 1
    fi

    # Check for vizier status
    vizier_status=0
    while [ "$vizier_status" -ne 1 ]; do
        if px get viziers -o json | jq -c '. | select(.ClusterName == "xgrid-website-migration") | .Status' &>/dev/null; then
            vizier_status=1
        fi
    done

    log "${GREEN}[PASSED]" "[INSTALLER]" "Pixie has been deployed to your cluster.${CC}"
    exit 0
}

px_installer
