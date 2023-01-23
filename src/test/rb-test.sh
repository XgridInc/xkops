#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh



namespaces=("default")
pod_verifier "${namespaces[@]}"