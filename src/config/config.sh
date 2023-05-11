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

#COLOR CODES
export CYAN='\033[0;36m' # Level = INFO
export RED='\033[0;31m' # Level = ERROR
export GREEN='\033[0;32m' # Level = PASSED
export CC="\033[0m"

# Get the Kubernetes API server URL and CA certificate path
export KUBERNETES_API_SERVER_URL="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
export CA_CERT_PATH="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# Read the service account token
SERVICE_ACCOUNT_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

# Set the HTTP headers
export HEADERS=("Authorization: Bearer $SERVICE_ACCOUNT_TOKEN")
export CLUSTER_NAME=$CLUSTER_NAME

