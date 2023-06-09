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

source /src/config/rb-config.sh
source /src/commons/common-functions.sh

print_prompt() {
    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Initiating pre-flight checks for Robusta installation in your cluster.${CC}"
}

check_values_file() {

    # This function checks if a generated_values.yaml file exists in the pre-flight directory. If the file does not exist, the function generates the file using rb_cli_checker and generate_values_file.

    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Searching for generated_values.yaml files.${CC}"
    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Pre-flight Directory: $PREFLIGHT_DIR_PATH${CC}."

    # Check if file exists in current directory (generated_values.yaml)
    if [[ -f "$PREFLIGHT_DIR_PATH/$HELM_VALUES" ]]; then
        log "${GREEN}[INFO]" "[PRE-FLIGHT]" "$HELM_VALUES found at $PREFLIGHT_DIR_PATH.${CC}"
    else
        # File not found
        # Check robusta-tool installation
        # Generate generated_values.yaml file
        log "${CYAN}[INFO]" "[PRE-FLIGHT]" "$HELM_VALUES not found in $PREFLIGHT_DIR_PATH. Generating...${CC}"
        if ! rb_cli_checker; then
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "Robusta CLI check failed. Exiting.${CC}"
            exit 1
        fi
        if ! generate_values_file "$HELM_VALUES"; then
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "Failed to generate $HELM_VALUES. Exiting.${CC}"
            exit 1
        fi
        if [[ -f "$PREFLIGHT_DIR_PATH/$HELM_VALUES" ]]; then
            log "${GREEN}[INFO]" "[PRE-FLIGHT]" "generated_values.yaml generated at $PREFLIGHT_DIR_PATH${CC}."
        else
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "generated_values.yaml not generated at $PREFLIGHT_DIR_PATH.${CC} Exiting...${CC}"
            log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Use Robusta CLI to create generated_values.yaml file at $PREFLIGHT_DIR_PATH.${CC}"
            exit 1
        fi
    fi
}

rb_cli_checker() {

    # This function checks if the Robusta CLI is installed and configured properly. If the Robusta CLI is not installed, the function will install it using rb_cli_installer.

    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Checking if Robusta-CLI is configured.${CC}"

    # Check if robusta-cli tool is present
    if command -v robusta &>/dev/null; then
        log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Robusta CLI is installed. $(robusta version).${CC}"
        return 0
    else
        # Install robusta-cli if not present
        log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Robusta CLI not found. Installing...${CC}"
        if ! rb_cli_installer; then
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "Failed to install Robusta CLI. Exiting...${CC}"
            log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Install Robusta CLI.${CC}"
            exit 1
        fi
        if command -v robusta &>/dev/null; then
            log "${GREEN}[INFO]" "[PRE-FLIGHT]" "Robusta CLI is installed. $(robusta version).${CC}"
            return 0
        else
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "Robusta CLI failed to install. Exiting...${CC}"
            log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Install Robusta CLI.${CC}"
            exit 1
        fi
    fi
}

rb_cli_installer() {
    #This functions installs pip and robusta-cli. Pip is required to install robusta-cli
    if command -v pip3 &>/dev/null; then
        pip3 install -U robusta-cli --no-cache &> /dev/null
        return
    else
        log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Python3-pip not found. Installing...${CC}"
        chmod 1777 /tmp
        apt update
        apt-get install -y python3-pip &> /dev/null
        if command -v pip3 &>/dev/null; then
            pip3 install -U robusta-cli --no-cache &> /dev/null
            return
        else
            log "${RED}[ERROR]" "[PRE-FLIGHT]" "pip3 failed to install. Exiting...${CC}"
            log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Install pip3.${CC}"
            exit 1
        fi
    fi
}

generate_values_file() {
    # Param $1 is filename
    # Used as output path of generated_values.yaml filepath/filename (filepath is coming from $PATH)

    log "${CYAN}[INFO]" "[PRE-FLIGHT]" "Generating generated_values.yaml file.${CC}"

    printf '%s\n' n n n y y n | robusta gen-config --slack-api-key "$SLACK_API_KEY" --slack-channel "$SLACK_CHANNEL_NAME" --cluster-name "$CLUSTER_NAME" --output-path "$PREFLIGHT_DIR_PATH/$1" > /dev/null
    # enabling persistent volume in robusta configuration file
    if ! grep -q 'playbooksPersistentVolume: true' "$PREFLIGHT_DIR_PATH/$HELM_VALUES"; then
        sed -i '4i\playbooksPersistentVolume: true' "$PREFLIGHT_DIR_PATH/$HELM_VALUES"
    fi
}

print_prompt
check_values_file
helm_checker
unpatch_default_storageclass
exit 0
