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

  #install pixie binary on container
  echo "y" | bash -c "$(curl -fsSL https://withpixie.ai/install.sh)" &>/dev/null

  #call get_eks_cluster_name to get the name of cluster
  #cluster_name=$(get_eks_cluster_name)

  log "${CYAN}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm..${CC}"
  helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com &>/dev/null
  helm repo update &>/dev/null
  helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName="${CLUSTER_NAME}" --namespace "${PLNS}" --create-namespace &>/dev/null
  log "${CYAN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available ${CC}"
  
  # Calling wait_for_deploy/pod function with namespace as an argument
  validate_healthy_deployment "$OLMNS"
  validate_healthy_deployment "$PXOPNS"
  validate_healthy_deployment "$PLNS"
  
  # check for vizier status
  vizierStatus=0
  while [ "$vizierStatus" -ne 1 ]; do
    vizierStatus=$(px get viziers -o json | jq -c '. | select(.ClusterName == "${CLUSTER_NAME}") | .Status')
  done
  log "${GREEN}[PASSED]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}

px_installer
