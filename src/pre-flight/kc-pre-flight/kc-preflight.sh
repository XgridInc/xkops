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

print_prompt() {
    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Initiating pre-flight checks for Kubecost installation to your K8s cluster.${CC}"
}

# Function to check if kubectl is installed in the cluster or not
kubectl_checker() {
    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Checking if kubectl is configured.${CC}"
    if command -v kubectl &>/dev/null; then
        log "${GREEN}[INFO]" "kubectl configurations are obtained successfully.${CC}"
    else
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "kubectl is not configured. Installing now.${CC}"
        kubectl_installer # Function call to install kubectl
    fi
}

# Function to install kubectl in the cluster
kubectl_installer() {
    # Downloads latest release of kubectl and installs
    _=$(curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl")
    _=$(chmod +x ./kubectl)
    _=$(mkdir -p "$HOME"/bin && cp ./kubectl "$HOME"/bin/kubectl && export PATH=$PATH:$HOME/bin)
    log "${GREEN}[INFO]" "[PRE-FLIGHT]" "kubectl is installed successfully.${CC}"
}

# Calling functions defined above
print_prompt
kubectl_checker
helm_checker
