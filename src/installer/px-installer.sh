#!/usr/bin/env bash

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

# The wrapper_function ensures that the deployment and pods in a namespace are fully operational by waiting for them to be in a running state.
wait_for_deployment() {
  while true; do
    dc=$(kubectl get deployments -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1 | wc -w)
    if [ "$dc" -gt 0 ]; then
      pods=$(kubectl get pods -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1)
      for pod in $pods; do
        while true; do
          status=$(kubectl get pods "$pod" -n "$1" -o jsonpath='{.status.phase}')
          if [[ $status == "Succeeded" || $status == "Running" ]]; then
            echo "Pod $pod reached the desired status: $status" 1> /dev/null
            break
          else
            echo "Waiting for pod $pod to reach the desired status: $status" 1> /dev/null
          fi
        done
      done
      break
    else
      echo "Number of deployment is Zero. Waiting for deployments to populate." 1> /dev/null
    fi
done
}

# Installing pixie on a containerized environment using Helm.
px_installer() {

  #install pixie binary on container
  echo "y" | bash -c "$(curl -fsSL https://withpixie.ai/install.sh)" >/dev/null

  #call get_eks_cluster_name to get the name of cluster
  #cluster_name=$(get_eks_cluster_name)
  log "${YELLOW}[INFO]" "[INSTALLER]" "Deploying Pixie using Helm..${CC}"
  helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com 1>/dev/null
  helm repo update 1>/dev/null
  helm install pixie pixie-operator/pixie-operator-chart --set deployKey="$PX_DEPLOY_KEY" --set clusterName=xgrid-website-migration --namespace pl --create-namespace >/dev/null
  log "${BROWN}[INFO]" "[INSTALLER]" "Waiting for Pixie deployments to become available ${CC}"
  
  # Calling wait_for_deploy/pod function with namespace as an argument
  wait_for_deployment "$OLMNS"
  wait_for_deployment "$PXOPNS"
  wait_for_deployment "$PLNS"
  
  #check for vizier status
  vizier_status=0
  while [ "$vizier_status" -ne 1 ]; do
    vizier_status=$(px get viziers -o json | jq -c '. | select(.ClusterName == "xgrid-website-migration") | .Status')
  done
  
  log "${GREEN}[INFO]" "[INSTALLER]" "Pixie has been deployed to your cluster${CC}"
  exit 0
}

px_installer
