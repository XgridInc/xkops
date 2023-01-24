#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh
source /src/config/rb-config.sh

print_prompt() {
    log_test "${CYAN}[INFO]" "[TEST]" "Initiating test plan for Robusta."

}

check_robusta_pod_status() {
    # checks if the pods in all the robusta namespaces are runnning or not.
    pod_status_verifier "$RB_NAMESPACE"
}

check_robusta_actions() {
    node=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
    results=$(robusta playbooks trigger node_running_pods_enricher name="$node" --namespace robusta )
    substring='"success":true'
    if echo "$results" | grep -q "$substring"; then
        log_test "${GREEN}[PASSED]" "[TEST]" "Robusta actions are working.${CC}"
        exit 0
    else
        log_test "${RED}[ERROR]" "[TEST]" "Robusta actions are not working.${CC}"
        exit 1
    fi

}

print_prompt
check_robusta_pod_status
check_robusta_actions
