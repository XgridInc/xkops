#!/usr/bin/env bash

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

# Installing pixie on a containerized environment using Helm.
px_installer() {
  log "${YELLOW}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm..${CC}"
  helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com 1>/dev/null
  helm repo update 1>/dev/null
  helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName=minikube --namespace pl --create-namespace >/dev/null
  log "${BROWN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available ${CC}"
  # Calling wait_for_deploy/pod function with namespace as an argument
  wait_for_deployment "$OLMNS"
  wait_for_deployment "$PXOPNS"
  wait_for_deployment "$PLNS"
  log "${GREEN}[INFO]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}

px_installer
