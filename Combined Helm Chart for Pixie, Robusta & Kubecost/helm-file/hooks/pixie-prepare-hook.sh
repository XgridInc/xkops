#!/bin/bash

# Colors for formatting output
RED='\033[1;31m'    # Bold red
GREEN='\033[1;32m'  # Bold green
YELLOW='\033[1;33m' # Bold yellow
NC='\033[0m'        # No color

# Function to print messages in red color
print_error() {
    echo -e "${RED}Error: $1${NC}"
}

# Function to print messages in green color
print_success() {
    echo -e "${GREEN}Success: $1${NC}"
}

# Function to print messages in yellow color
print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to install Pixie CLI
install_pixie_cli1() {

    echo "Downloading Pixie CLI binary..."
    
    # Command to install the Pixie CLI.
    bash -c "$(curl -fsSL https://withpixie.ai/install.sh)"

}
# Function to create Pixie deploy key
create_pixie_deploy_key() {
    echo "Step 2: Creating Pixie deploy key..."
    DEPLOY_KEY=$(sudo px deploy-key create)
    echo "$DEPLOY_KEY"
}

# Main function
main() {
    echo "Starting Pixie installation preparation..."

    install_pixie_cli1
    create_pixie_deploy_key

    print_success "Pixie installation preparation completed."
}

# Execute the main function
main