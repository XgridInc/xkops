#!/bin/bash

# Colors for formatting output
RED='\033[1;31m'    # Bold red
GREEN='\033[1;32m'  # Bold green
YELLOW='\033[1;33m' # Bold yellow
NC='\033[0m'        # No color

# Function to print messages in color
print_message() {
  local color="$1"
  local message="$2"
  echo -e "${color}$message${NC}"
}

# Function to print success messages
print_success() {
  print_message "$GREEN" "$1"
}

# Function to print error messages
print_error() {
  print_message "$RED" "Error: $1"
}

# Function to print warning messages
print_warning() {
  print_message "$YELLOW" "Warning: $1"
}

# Function to check if kubectl command exists
check_kubectl_installed() {
  if ! command -v kubectl &> /dev/null; then
    print_error "kubectl command not found. Please install kubectl."
    return 1
  fi
  return 0
}

# Function to check if port forwarding is already active
is_port_forwarded() {
  # Local port for accessing Kubecost UI (default 9090)
  local PORT=80

  # Check if process exists using ss command (replace with netstat if ss is unavailable)
  if ss -aln | grep "LISTEN" | grep ":$PORT "; then
    print_warning "Port $PORT is already forwarded for another process. Consider using a different port for Kubecost UI."
    return 1
  fi
  return 0
}

# Function to perform port forwarding for Kubecost
kubecost_port_forward() {
  # Comments explaining the purpose
  # This function establishes port forwarding from your local machine port (default 9090)
  # to the Kubecost cost-analyzer container port (default 9090), assuming the UI runs on that port.

  # Local port for accessing Kubecost UI (default 9090)
  local PORT=80

  # Namespace where Kubecost deployment resides (replace with your actual namespace)
  local KUBECOST_NAMESPACE="kubecost"

  # Deployment name for Kubecost cost-analyzer (replace with your actual deployment name)
  local KUBECOST_DEPLOYMENT="kubecost-cost-analyzer"

  check_kubectl_installed || return 1

  # Attempt to forward the port
  kubectl port-forward --namespace "$KUBECOST_NAMESPACE" "deployment/$KUBECOST_DEPLOYMENT" "$PORT" &> /dev/null &

  # Check if background process started successfully
  if [ $? -eq 0 ]; then
    print_success "Port forwarding for Kubecost UI enabled on port $PORT."
  else
    print_error "Failed to establish port forwarding for Kubecost UI."
    return 1
  fi
}

# Main script (optional, for standalone execution)
main() {
  # Check if port forwarding is already active
  is_port_forwarded || kubecost_port_forward
}

# If script is sourced, don't run the main function
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  return 0
fi

main
