#!/bin/bash

source /src/config/config.sh

#rb-preflight path
export RB_PREFLIGHT_SCRIPT_PATH=/src/pre-flight/rb-pre-flight/rb-preflight.sh
#rb-installer path
export RB_INSTALLER_SCRIPT_PATH=/src/installer/rb-installer.sh

#rb-preflight directory path
export PREFLIGHT_DIR_PATH=/src/pre-flight/rb-pre-flight

# Set expected image names
export EXPECTED_RUNNER_IMAGE="us-central1-docker.pkg.dev/genuine-flight-317411/devel/robusta-runner:0.10.8"
export EXPECTED_FORWARDER_IMAGE="us-central1-docker.pkg.dev/genuine-flight-317411/devel/kubewatch:v2.0"

#Set expected values for runner and forwarder deployments
export EXPECTED_RUNNER_NAME="robusta-runner"
export EXPECTED_FORWARDER_NAME="robusta-forwarder"


#TODO: Give option to upload generated_values.yaml file through UI
export HELM_VALUES=generated_values.yaml #File required to installed robusta

# TODO: To be taken from user from UI
# read -rp 'Enter cluster name: ' cluster_name
# read -rp 'Enter slack api key: ' slack_api_key
# read -rp 'Enter slack channel name: ' slack_channel_name

#These values are coming from environment variables set on container
export CLUSTER_NAME=$CLUSTER_NAME
export SLACK_API_KEY=$SLACK_API_KEY
export SLACK_CHANNEL_NAME=$SLACK_CHANNEL_NAME
export ROBUSTA_UI_API_KEY=$ROBUSTA_UI_API_KEY
