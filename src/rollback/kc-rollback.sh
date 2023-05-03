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

source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/kc-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[ROLLBACK]" "Initiating rollback of Kubecost in your cluster.${CC}"
}

#Rollback function for kubecost
kc_rollback() {
    helm uninstall kubecost -n "${KC_NAMESPACE[@]}" &>/dev/null
    kubectl delete namespace "${KC_NAMESPACE[@]}" &>/dev/null
    log "${GREEN}[PASSED]" "[ROLLBACK]" "Kubecost has been deleted from your cluster${CC}"
}
print_prompt
kc_rollback
