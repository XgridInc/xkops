#!/bin/bash

#COLOR CODES
export CYAN='\033[0;36m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export CC="\033[0m"
export PURPLE='\033[0;35m'
export BOLD_CYAN="\033[1;36m"
export BOLD_RED="\033[1;31m"
export BOLD_GREEN="\033[1;32m"
export BROWN='\033[0;33m'
export BBROWN='\033[1;33m'

# Get the Kubernetes API server URL and CA certificate path
export KUBERNETES_API_SERVER_URL="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
export CA_CERT_PATH="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# Read the service account token
SERVICE_ACCOUNT_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

# Set the HTTP headers
export HEADERS=("Authorization: Bearer $SERVICE_ACCOUNT_TOKEN")

