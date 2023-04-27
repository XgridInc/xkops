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
#waits for 5 minutes and then call rollback functions.
pixie_rollback() {

    # This function uninstalls and deletes the pixie helm release and namespace using helm uninstall and kubectl delete commands, respectively.

    if helm uninstall pixie -n pl &>/dev/null; then
        log "${GREEN}[PASSED]" "[ROLLBACK]" "Pixie has been uninstalled from your cluster.${CC}"
    else
        log "${RED}[ERROR]" "[ROLLBACK]" "Failed to uninstall Pixie from your cluster. Exiting...${CC}"
        exit 1
    fi

    if kubectl delete namespace pl &>/dev/null; then
        log "${GREEN}[PASSED]" "[ROLLBACK]" "Pixie namespace has been deleted from your cluster.${CC}"
    else
        log "${RED}[ERROR]" "[ROLLBACK]" "Failed to delete Pixie namespace from your cluster. Exiting...${CC}"
        exit 1
    fi
      log "${GREEN}[INFO]" "[ROLLBACK]" "Pixie has been deleted from your cluster${CC}"
}
# pixie_rollback(){
#   helm uninstall pixie -n pl &>/dev/null
#   kubectl delete namespace pl &>/dev/null
#   log "${GREEN}[INFO]" "[ROLLBACK]" "Pixie has been deleted from your cluster${CC}"
# }
pixie_rollback
