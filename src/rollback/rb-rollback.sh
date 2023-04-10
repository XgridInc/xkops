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
    log "${CYAN}[INFO]" "[ROLLBACK]" "Initiating rollback of Robusta in your cluster.${CC}"
}

rb_rollback() {
    if command -v helm &>/dev/null; then
        #Uninstall robusta using helm
        helm uninstall robusta -n robusta > /dev/null
        kubectl delete namespace robusta > /dev/null
        log "${GREEN}[PASSED]" "[ROLLBACK]" "Robusta has been deleted from your cluster${CC}"
    else
        # If Helm is not installed, print an error message and exit.
        log "${RED}[ERROR]" "[ROLLBACK]" "Helm is not installed. Exiting...${CC}"
        log "${CYAN}[INFO]" "[ROLLBACK]" "Install Helm.${CC}"
        exit 1
    fi
}

print_prompt
rb_rollback
