#!/bin/bash

source /src/config/kc-config.sh
source /src/commons/common-functions.sh


# Installer function for Kubecost
kc_installer() {
    kubecostDeploy=$(kubectl -n kubecost get deploy --no-headers 2>&1 | grep -i kubecost-cost-analyzer | awk '{print $1}')
    if [ "$kubecostDeploy" == "kubecost-cost-analyzer" ]; then
        log "${BOLD_GREEN}[INFO]" "[INSTALLER]" "$PURPLE Kubecost$CC ${BOLD_GREEN}already found in the cluster.${CC}"
        exit 0
    else
        log "${BOLD_RED}[ERROR]" "[INSTALLER]" "Unable to find kubecost Deployment in cluster. Installing kubecost now...${CC}"

        # It creates a namespace called kubecost, Adds repo in helm and installs kubecost
        _=$(
            helm repo add kubecost https://kubecost.github.io/cost-analyzer/
            helm install kubecost kubecost/cost-analyzer -n kubecost --create-namespace
        )

        # Wait till kubecost prometheus-server pod is ready.
        _=$(kubectl -n kubecost wait pod --for=condition=Ready -l component=server --timeout=1h)
        log "${BOLD_GREEN}[INFO]" "[INSTALLER]" "Kubecost installed successfully.${CC}"
    fi
}

# Calling functions defined above
kc_installer
