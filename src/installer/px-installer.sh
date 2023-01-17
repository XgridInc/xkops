#!/usr/bin/env bash

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

# Wrapper function to check for a deployment in a namespace. If this is not use, we have to use either timeout or sleep commands
wrapper_function() {
  while true; do
    dc=$(kubectl get deployments -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1 | wc -w)
    if [ "$dc" -gt 0 ]; then
      break
    fi
    kubectl wait deployment "$2" --for=condition=Available -n "$1" --timeout=1h 2> /dev/null
  done
}

# Installing pixie on a containerized environment using Helm.
px_installer() {

  log "${YELLOW}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm..${CC}"
  helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com 1>/dev/null
  helm repo update 1>/dev/null
  helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName=minikube --namespace pl --create-namespace >/dev/null
  log "${BROWN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available ${CC}"

  wrapper_function "olm" "catalog-operator"
  wrapper_function "olm" "olm-operator"
  wrapper_function "px-operator" "vizier-operator"
  wrapper_function "pl" "kelvin"

  log "${GREEN}[INFO]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}
px_installer
