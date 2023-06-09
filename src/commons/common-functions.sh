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


log() {

    # Parameters
    # :var level: Type of level = ERROR PASSED INFO.
    # :var function: From which script the log is coming.
    # :var message: Message to log

    #This functions saves the messages passed to it in /tmp/app.log path.

    local level=$1
    local function=$2
    local message=$3
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $level $function $message" | tee -a /tmp/app.log
}

log_test() {

    # Parameters
    # :var level: Type of level = ERROR PASSED INFO.
    # :var function: From which script the log is coming.
    # :var message: Message to log

    #This functions saves the messages passed to it in /tmp/app_test.log path.

    local level=$1
    local function=$2
    local message=$3
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $level $function $message" | tee -a /tmp/app_test.log
}


helm_checker() {

    # Parameters
    # :None

    # Function to check if helm is installed in the cluster

    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Checking if helm is configured.${CC}"
    if command -v helm &>/dev/null; then
        log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Helm configurations obtained successfully.${CC}"
        exit 0
    else
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Helm is not installed. Installing it now.${CC}"
        helm_installer # Function call to install helm
    fi
}

helm_installer() {

    # Parameters
    # :None

    # This function downloads helm 3 binary using curl and installs it.

    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Downloading and installing Helm.${CC}"

    if curl -s -O https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz >/dev/null &&
        tar -zxvf helm-v3.10.0-linux-amd64.tar.gz >/dev/null &&
        cp ./linux-amd64/helm /usr/local/bin/; then
        if command -v helm &>/dev/null; then
            log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Helm has been installed successfully.${CC}"
            return 0
        else
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "Helm is not installed. Exiting...${CC}"
            return 1
        fi
    else
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Failed to download and install Helm. Exiting...${CC}"
        return 1
    fi
}
check_permissions() {

    # Parameters
    # :None

    # This function checks if service account has permission to list deployments.
    # If the service account has no permissions then the script will terminate.

    forbiddenError="Forbidden"

    log "${CYAN}[INFO]" "[CHECKER]" "Checking if service account has permissions to list deployments.${CC}"

    deployments=$(curl --silent "$KUBERNETES_API_SERVER_URL/apis/apps/v1/deployments" \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}")
    errorCode=$?
    if [ $errorCode -ne 0 ]; then
        log "${RED}[ERROR]" "[CHECKER]" "Failed to get deployment permissions. Exiting...${CC}"
        exit 1
    fi

    # Extract the "reason" field from the response.
    reason=$(echo "$deployments" | grep -o '"reason": "[^"]*')

    # Check if the "reason" field contains the word "Forbidden"
    if [[ $reason == *"$forbiddenError"* ]]; then
        log "${RED}[ERROR]" "[CHECKER]" "Forbidden, cannot list deployments. Exiting.${CC}"
        log "${CYAN}[INFO]" "[CHECKER]" "Create clusterrole and clusterrole binding with enough permissions.${CC}"
        exit 1
    else
        log "${GREEN}[INFO]" "[CHECKER]" "Service account has permissions to list deployments.${CC}"
    fi
}

pod_status_verifier() {

    # Parameters
    # :var namespaces: (list) | A list of namespaces

    #This function check if the namespace exists
    #If it exists it checks whether all the pod in the namespace is running or not.

    log_test "${CYAN}[INFO]" "[TEST]" "Verifying the status of pods related to the tool. ${CC}"

    namespaces=("${@}")
    for namespace in "${namespaces[@]}"; do

        if kubectl get namespace "$namespace" &>/dev/null; then

            # Get a list of pods in the namespace
            pods=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}')

            # Iterate over pods in the namespace to verify their status
            for pod in $pods; do
                podStatus=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.phase}')

                # If pod status is not Running or Completed, tool is not deployed successfully.
                if [[ "$podStatus" != "Running" && "$podStatus" != "Succeeded" ]]; then

                    log_test "${RED}[ERROR]" "[TEST]" "$pod pod in  $namespace namespace is not in Running state.${CC}"
                else
                    log_test "${GREEN}[PASSED]" "[TEST]" "$pod pod in $namespace namespace is in Running state.${CC}"
                fi
            done
        else
            log_test "${RED}[ERROR]" "[TEST]" "Namespace $namespace does not exist.${CC}"
        fi

    done
}

get_eks_cluster_name() {

    # Parameters
    # :None

    # this function fetches the eks cluster name and returns it


    # Get the current context of the kubeconfig
    currentContext=$(kubectl config current-context)

    # Get the cluster name associated with the current context
    clusterName=$(kubectl config get-contexts "$currentContext" | awk '{print $3}' | grep -Eo 'arn:aws:eks:[a-zA-Z0-9-]*:[0-9]*:[cluster/[a-zA-Z0-9-]*|@[a-zA-Z0-9-]*')
    if [[ -z $clusterName ]]; then
        log "${RED}[ERROR]" "[CHECKER]" "Failed to get EKS cluster name. Exiting.${CC}"
        exit 1
    else
        export clusterName
        rm -rf root/.kube/config
        # Print the cluster name
        return "$clusterName"
    fi
}

# The wrapper_function ensures that the deployment and pods in a namespace are fully operational by waiting for them to be in a running state.
validate_healthy_deployment() {
  while true; do
    dc=$(kubectl get deployments -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1 | wc -w)

    # Check to see if atleast one deployment can be found in the namespace.
    if [ "$dc" -gt 0 ]; then
      pods=$(kubectl get pods -n "$1" -o jsonpath='{.items[*].metadata.name}' | cut -d'%' -f1)
      for pod in $pods; do
        while true; do
          status=$(kubectl get pods "$pod" -n "$1" -o jsonpath='{.status.phase}')

          # Check if Pods Phase reached running or succeeded.
          if [[ $status == "Succeeded" || $status == "Running" ]]; then
            log "Pod $pod reached the desired status: $status" 1> /dev/null
            break
          else
            log "Waiting for pod $pod to reach the desired status: $status" 1> /dev/null
          fi
        done
      done
      break
    else
      log "Waiting for deployments to become available." 1> /dev/null
    fi
done
}

unpatch_default_storageclass() {
    #unpatching default gp2 storage class
    kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}
