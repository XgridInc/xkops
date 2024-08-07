#!/bin/bash

# Colors for formatting output
RED='\033[1;31m'    # Bold red
GREEN='\033[1;32m'  # Bold green
YELLOW='\033[1;33m' # Bold yellow
NC='\033[0m'        # No color

# Function to print messages in red color
print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to print messages in green color
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print messages in yellow color
print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to display error message and exit
print_error_and_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to install Helmfile if not already installed
install_helmfile() {
    # Check if Helmfile is already installed
    if ! command -v helmfile &> /dev/null; then
        echo "Installing Helmfile..."
        # Download Helmfile
        sudo wget https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
        # Extract Helmfile
        sudo tar -xf helmfile_0.159.0_linux_amd64.tar.gz
        # Remove the downloaded archive
        sudo rm helmfile_0.159.0_linux_amd64.tar.gz
        # Move Helmfile to /usr/local/bin
        sudo mv helmfile /usr/local/bin/
        # Check for errors and handle accordingly
        if [ $? -ne 0 ]; then
            print_error_and_exit "Failed to move Helmfile to /usr/local/bin."
        fi
        print_success "Helmfile installed successfully."
    else
        echo "Helmfile is already installed. Skipping installation."
    fi
}

# Function to set execution permissions for hook scripts
set_permissions() {
    echo "Setting execution permissions for scripts in helm-file/hooks..."
    chmod +x helm-file/hooks/*.sh
    # Check for errors and handle accordingly
    if [ $? -ne 0 ]; then
        print_error_and_exit "Failed to set execution permissions for hook scripts."
    fi
    print_success "Execution permissions set successfully."
}

# Function to run Helmfile commands
run_helmfile() {
    echo "Running Helmfile..."
    helmfile --file helm-file/helmfile.yaml sync 2>&1 | tee helmfile_output.log
    local status=${PIPESTATUS[0]}
    if [ $status -ne 0 ]; then
        print_error "Failed to run Helmfile."
    else
        print_success "Helmfile commands executed successfully."
    fi
    return $status
}

# Main function to execute the installation process
main() {
    install_helmfile
    set_permissions
    run_helmfile
}

# Execute main function
main
