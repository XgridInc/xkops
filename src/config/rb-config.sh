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

source /src/config/config.sh

export RB_NAMESPACE=("robusta")

#rb-preflight path
export RB_PREFLIGHT_SCRIPT_PATH=/src/pre-flight/rb-pre-flight/rb-preflight.sh
#rb-installer path
export RB_INSTALLER_SCRIPT_PATH=/src/installer/rb-installer.sh

#rb-preflight directory path
export PREFLIGHT_DIR_PATH=/src/pre-flight/rb-pre-flight
export PLAYBOOK_DIR_PATH=/src/installer/rb-actions
# Set expected image names
export EXPECTED_RUNNER_IMAGE="us-central1-docker.pkg.dev/genuine-flight-317411/devel/robusta-runner"
export EXPECTED_FORWARDER_IMAGE="us-central1-docker.pkg.dev/genuine-flight-317411/devel/kubewatch"

#Set expected values for runner and forwarder deployments
export EXPECTED_RUNNER_NAME="robusta-runner"
export EXPECTED_FORWARDER_NAME="robusta-forwarder"
export NAMESPACE="robusta"

#TODO: Give option to upload generated_values.yaml file through UI
export HELM_VALUES=generated_values.yaml #File required to installed robusta

# TODO: To be taken from user from UI
# read -rp 'Enter cluster name: ' cluster_name
# read -rp 'Enter slack api key: ' slack_api_key
# read -rp 'Enter slack channel name: ' slack_channel_name

#These values are coming from environment variables set on container

export SLACK_API_KEY=$SLACK_API_KEY
export SLACK_CHANNEL_NAME=$SLACK_CHANNEL_NAME
export ROBUSTA_UI_API_KEY=$ROBUSTA_UI_API_KEY
