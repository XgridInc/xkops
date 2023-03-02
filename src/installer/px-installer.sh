#!/usr/bin/env bash

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

# Installing pixie on a containerized environment using Helm.
px_installer() {

  #install pixie binary on container
  echo "y" | bash -c "$(curl -fsSL https://withpixie.ai/install.sh)" &>/dev/null

  #call get_eks_cluster_name to get the name of cluster
  #cluster_name=$(get_eks_cluster_name)

  # Checking Helm in this function. If Helm is present, use it to install Pixie.
  helm_checker

  log "${CYAN}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm..${CC}"
  helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com &>/dev/null
  helm repo update &>/dev/null
  helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName=xgrid-website-migration --namespace pl --create-namespace &>/dev/null
  log "${CYAN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available ${CC}"
  
  # Calling wait_for_deploy/pod function with namespace as an argument
  validate_healthy_deployment "$OLMNS"
  validate_healthy_deployment "$PXOPNS"
  validate_healthy_deployment "$PLNS"
  
  # check for vizier status
  vizier_status=0
  while [ "$vizier_status" -ne 1 ]; do
    vizier_status=$(px get viziers -o json | jq -c '. | select(.ClusterName == "xgrid-website-migration") | .Status')
  done
  log "${GREEN}[PASSED]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}

px_installer
