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
  log "${BROWN}[INFO]" "[INSTALLER]" "Waiting for Pixie deplyments to become available ${CC}"
  kubectl wait deployment catalog-operator -n olm --for=condition=Available --timeout=1h 1>/dev/null
  kubectl wait deployment olm-operator -n olm --for=condition=Available --timeout=1h 1>/dev/null
  sleep 60
  kubectl wait deployment vizier-operator -n px-operator --for=condition=Available --timeout=1h 1>/dev/null
  sleep 40
  kubectl wait deployment kelvin -n pl --for=condition=Available --timeout=1h 1>/dev/null
  log "${GREEN}[INFO]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}
px_installer
