#!/bin/bash

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

