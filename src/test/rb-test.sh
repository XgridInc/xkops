#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/rb-config.sh

print_prompt() {
    log "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Robusta."

}

check_robusta_pod_status() {
    # checks if the pods in all the robusta namespaces are runnning or not.
    pod_status_verifier "$RB_NAMESPACE"
}
