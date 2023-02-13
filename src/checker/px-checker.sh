#!/bin/bash

source /src/config/px-config.sh
source /src/config/config.sh
source /src/commons/common-functions.sh

print_prompt() {

    # px_checker.sh: Script to detect Pixie in a K8s cluster.
    log "${CYAN}[INFO]" "[CHECKER]" "Starting checks to detect Pixie in Kubernetes cluster.${CC}"
    log "${CYAN}[INFO]" "[CHECKER]" "Current Context: $currentCtx${CC}"
}

#check whether the service account has permision to list deployments.
check_permissions

# CLUSTER BASED CHECKS
# 1.0 Pixie namesapces check using kubectl.
# If kubectl exists on the system this function uses kubectl to find the Pixie relevant namespaces.
# If any of the Pixie namespaces is not found, it returns with a non-zero exit code.
kubectl_pxNS_checker() {

    if ! kubectl get pods &>/dev/null; then
        log "${CYAN}[INFO]" "[CHECKER]" "kubectl exists, but can not reach kube_api server. Using curl instead.${CC}"
        curl_pxNS_checker
    else
        olm_check=$(kubectl get ns | grep "$OLMNS" | awk '{print $1}')
        pl_check=$(kubectl get ns | grep "$PLNS" | awk '{print $1}')
        pxOp_check=$(kubectl get ns | grep "$PXOPNS" | awk '{print $1}')

        if [[ "$olm_check" == olm && "$pl_check" == pl && "$pxOp_check" == px-operator ]]; then
            log "${GREEN}[PASSED]" "[CHECKER]" "Pixie namespaces found.${CC}"
        else
            log "${RED}[ERROR]" "[CHECKER]" "Pixie namespaces not found. ${CC}"
            log "${RED}[ERROR]" "[CHECKER]" "Pixie not found in the cluster${CC}"
            exit 0
        fi
    fi
}

# 1.1- Pixie namesapces check using curl.
# If kubectl doesn't exist on the system this function uses curl to directly talk to kube_api server
# to find the namespaces. If any of the Pixie namespaces is not found, it returns with a non-zero exit code.
curl_pxNS_checker() {

    # these namespaces are pixie's specific and all the pixie's components are
    # deployed in those namespaces.
    declare -a arr=("$OLMNS" "$PXOPNS" "$PLNS")

    for namespace in "${arr[@]}"; do
        ns=$(ns=$(curl --silent "$KUBERNETES_API_SERVER_URL/api/v1/namespaces" \
            --cacert "$CA_CERT_PATH" \
            --header "${HEADERS[@]}" |
            grep -i "$namespace" | grep name | head -2 | grep -oP '(?<="name": ")[^"]*'))
        if [[ $ns != "$namespace" ]]; then
            log "${RED}[ERROR]" "[CHECKER]" "$namespace namespace not found.${CC}"
            log "${RED}[ERROR]" "[CHECKER]" "Pixie not found in the cluster${CC}"
            exit 0
        else
            log "${GREEN}[PASSED]" "[CHECKER]" "$namespace namespace found.${CC}"
            exit 1
        fi
    done
}

# 2.1- Pixie deployments check using kubectl.
# This function tries to check for Pixie deployments in the Pixie namespaces.
# If deployments are not found the script exits with a non-zero status code.
kubectl_pxDeploy_checker() {

    mapfile -t plDeploy < <(kubectl get deploy -n "$PLNS" --no-headers 2>checker.log | awk '{print $1}')
    mapfile -t olmDeploy < <(kubectl get deploy -n "$OLMNS" --no-headers 2>checker.log | awk '{print $1}')

    if [[ ${#plDeploy[*]} -ne 0 && ${#olmDeploy[*]} -ne 0 ]]; then

        for dp in "${plDeploy[@]}"; do
            ns="$PLNS"
            if [[ $dp == "$PL_KELVIN" || $dp == "$PL_CLOUD_CONNECTOR" || $dp == "$PL_VIZIER_QUERY_BROKER" ]]; then
                log "${GREEN}[PASSED]" "[CHECKER]" "$dp deployment found in $ns namespace.${CC}"
            else
                log "${CYAN}[INFO]" "[CHECKER]" "$dp deployment not found in $ns namespace.${CC}"

            fi
        done

        for dp in "${olmDeploy[@]}"; do
            ns="$OLMNS"
            if [[ $dp == "$OLM_CATALOG_OPERATOR" || $dp == "$OLM_OPERATOR" ]]; then
                log "${CYAN}[PASSED]" "[CHECKER]" "$dp deployment found in $ns namespace.${CC}"
                exit 1
            else
                log "${CYAN}[INFO]" "[CHECKER]" "$dp deployment not found in $ns namespace.${CC}"
                log "${CYAN}[INFO]" "[CHECKER]" "Pixie not found in the cluster${CC}"
                exit 0
            fi
        done

    else
        log "${CYAN}[INFO]" "[CHECKER]" "Pixie not found in the cluster${CC}"
        exit 0
    fi
}

if command -v kubectl &>/dev/null; then
    currentCtx=$(kubectl config current-context)
    print_prompt
    check_permissions
    log "${CYAN}[INFO]" "[CHECKER]" "Checking for Pixie namespaces in the current cluster.${CC}"
    kubectl_pxNS_checker
    log "${CYAN}[INFO]" "[CHECKER]" "Checking for Pixie Deployments in the current cluster.${CC}"
    kubectl_pxDeploy_checker
else
    currentCtx=$(kubectl config current-context)
    print_prompt
    check_permissions
    log "${CYAN}[INFO]" "[CHECKER]" "Checking for Pixie namespaces in the current cluster.${CC}"
    log "${RED}[ERROR]" "[CHECKER]" "kubectl not found. Using curl instead.${CC}"
    curl_pxNS_checker
fi
