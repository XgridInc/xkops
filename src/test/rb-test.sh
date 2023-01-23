#!/bin/bash
source /src/commons/common-functions.sh
source /src/config/config.sh



namespaces=("robusta")
pod_status_verifier "${namespaces[@]}"