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

source /src/config/config.sh
source /src/commons/common-functions.sh

print_prompt() {
    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Initiating pre-flight checks for Pixie installation to your K8s cluster.${CC}"
}

preFlight_checks() {
    #   1. Kubernetes Version Check. Supports 1.21+
    version=$(curl -s "$KUBERNETES_API_SERVER_URL/version" \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}" |
        grep -oP '(?<="gitVersion": ")[^"]*')
    mapfile -t kVers < <(curl -s "$KUBERNETES_API_SERVER_URL/version" \
        --cacert "$CA_CERT_PATH" \
        --header "${HEADERS[@]}" |
        grep -oP '(?<="gitVersion": ")[^"]*' | tr -d 'v' | tr '.' '\n')

    if [[ "${kVers[0]}" -lt 1 && "${kVers[1]}" -le 21 ]]; then
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Unsupported K8s Version: $version. Pixie supports Kubernetes version 1.21+.${CC}"
        exit 1
    fi

    # 2. Linux Kernel Version Check. Supports 4.14+
    majorVer=$(awk -F . '{print $1}' <<<"$(uname -r)")
    minorVer=$(awk -F . '{print $2}' <<<"$(uname -r)")

    if [[ $majorVer -lt 4 && $minorVer -le 14 ]]; then
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Unsupported Linux Kernel Version: $(uname -r).Pixie supports Linux Kernel version 4.14+.${CC}"
        exit 1
    fi

    #3. CPU check. Supports x86_64.
    cpuArch="$(lscpu | grep Architecture | awk '{print $2}')"
    reqArch="x86_64"
    if [[ "$cpuArch" != "$reqArch" ]]; then
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Unsupported Architecture: $cpuArch.Pixie only supports x86_64 architecture.${CC}"
        exit 1
    fi

    #4. Memory Check. Requires 1Gi per node.
    freeMem=$(free -g | awk '{print $4}' | head -2 | tail -1)
    if [ "$freeMem " -lt 0 ]; then
        log "${RED}[ERROR]" "[PRE-FLIGHT]" "Not enough memory on the node. Pixie requires minimum 1 Gib memory per node.${CC}"
        exit 1
    fi
    log "${GREEN}[PASSED]" "[PRE-FLIGHT]" "Pre-flights checks passed. Initiating installation...${CC}"
}

print_prompt
preFlight_checks
helm_checker
