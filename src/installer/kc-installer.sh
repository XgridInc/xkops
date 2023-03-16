#!/bin/bash

source /src/config/kc-config.sh
source /src/commons/common-functions.sh

# Installer function for Kubecost
kc_installer() {
    kubecostDeploy=$(kubectl -n kubecost get deploy --no-headers 2>&1 | grep -i kubecost-cost-analyzer | awk '{print $1}')
    if [ "$kubecostDeploy" == "kubecost-cost-analyzer" ]; then
        log "${GREEN}[INFO]" "[INSTALLER]" "Kubecost ${GREEN}already found in the cluster.${CC}"
        exit 0
    else
        log "${RED}[ERROR]" "[INSTALLER]" "Unable to find kubecost Deployment in cluster. Installing kubecost now...${CC}"

        # It creates a namespace called kubecost, Adds repo in helm and installs kubecost
        _=$(
            helm repo add kubecost https://kubecost.github.io/cost-analyzer/
            helm install kubecost kubecost/cost-analyzer -n kubecost --create-namespace 2>&1
        )

        # Wait till kubecost prometheus-server pod is ready.
        _=$(kubectl -n kubecost wait pod --for=condition=Ready -l component=server --timeout=1h)
        create_kc_service
    fi
}

create_kc_service() {
    kubectl -n kubecost expose deployment kubecost-cost-analyzer --port=80 --target-port=9090 --name=kubecost-ui-service --type=LoadBalancer &>/dev/null
}

# Calling functions defined above
kc_installer
