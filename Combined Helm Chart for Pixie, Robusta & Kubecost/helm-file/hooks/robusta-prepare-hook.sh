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

# Function to check if Python is already installed
check_python_installed() {
    if ! command -v python3 &> /dev/null; then
        echo "Python is not installed."
        return 1
    fi
    echo "Python is already installed."
    return 0
}

# Function to check if Robusta CLI is already installed
check_robusta_cli_installed() {
    if ! command -v robusta &> /dev/null; then
        echo "Robusta CLI is not installed."
        return 1
    fi
    echo "Robusta CLI is already installed."
    return 0
}

# Function to install Python and create a virtual environment
install_python_and_create_venv() {
    check_python_installed || sudo apt-get -y install python3 python3-pip
    print_success "Python installed successfully."

    if [ ! -d ".venv" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv .venv
        print_success "Virtual environment created successfully."
    else
        echo "Python virtual environment already exists."
    fi
}

# Function to activate the Python virtual environment
activate_venv() {
    echo "Activating Python virtual environment..."
    source .venv/bin/activate
}

# Function to install Robusta CLI
install_robusta_cli() {
    check_robusta_cli_installed || pip3 install -U robusta-cli --no-cache &> /dev/null &
    print_success "Robusta CLI installed successfully."
}


# Function to print messages in yellow color
print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to extract values from values.yaml
get_yaml_value() {
  # Function arguments:
  # - $1: Path to the YAML file
  # - $2: Name of the value to retrieve

  local value
  value=$(grep -E "^\s*($2):\s*" "$1" | awk -F: '{$1=""; print $2}')
  echo "${value//\"/}"  # Remove any surrounding quotes
}


# Function to find and validate the path to values.yaml
find_values_file_path() {
  # Check for values.yaml in the current directory
  if [[ -f "./values.yaml" ]]; then
    echo "./values.yaml"
  else
    # If not found, search upwards in parent directories
    search_dir="$PWD"
    while [[ "$search_dir" != "/" ]]; do
      if [[ -f "$search_dir/values.yaml" ]]; then
        echo "$search_dir/values.yaml"
        return 0
      fi
      search_dir=$(dirname "$search_dir")
    done
  fi
}

# Function to generate Robusta configuration
generate_robusta_config() {
    echo "Generating Robusta configuration..."

    # Call the function and store the path (if found)
    YAML_FILE=$(find_values_file_path)

    # Check the function's return status
    if [[ -z "$YAML_FILE" ]]; then
    print_error "Error: Could not find 'values.yaml' file in the current directory or parent directories. Make sure you have values.yaml file"
    else
    print_success "Found values.yaml file at: $YAML_FILE"
    fi

    SLACK_API_KEY=$(get_yaml_value "$YAML_FILE" "slack_api_key")
    SLACK_CHANNEL_NAME=$(get_yaml_value "$YAML_FILE" "slack_channel_name")
    CLUSTER_NAME=$(get_yaml_value "$YAML_FILE" "cluster_name")

    echo "Slack API Key: $SLACK_API_KEY"
    echo "Slack Channel Name: $SLACK_CHANNEL_NAME"
    echo "Cluster Name: $CLUSTER_NAME"

    # Get the script's output directory   
    GENERATED_VALUES_DIR=$(get_yaml_value "$YAML_FILE" "generated_values_path")

    # Remove leading whitespace to get correct path
    GENERATED_VALUES_DIR=$(echo "$GENERATED_VALUES_DIR" | sed 's/^\s*//')  

    echo "GENERATED_VALUES_DIR: $GENERATED_VALUES_DIR"

    # Generate robusta configuration with output path in script directory
    printf '%s\n' n n n y y n | robusta gen-config  --slack-api-key "$SLACK_API_KEY" --slack-channel "$SLACK_CHANNEL_NAME" --cluster-name "$CLUSTER_NAME" --output-path "$GENERATED_VALUES_DIR"
    
    print_success "Robusta configuration generated successfully."
}


# Main function
main() {
    echo "Starting Robusta installation preparation..."

    install_python_and_create_venv
    activate_venv
    install_robusta_cli
    generate_robusta_config

    echo "$generate_robusta_config"
    echo "Robusta installation preparation completed."
}

# Execute the main function
main
