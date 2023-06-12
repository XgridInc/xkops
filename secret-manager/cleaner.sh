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

# at the end of commands you would see 2>&1 is fetch both response that is in STDOUT and STDERR for more info read this: https://askubuntu.com/questions/812952/cant-capture-output-into-variable-in-bash

response=$(helm repo remove secrets-store-csi-driver 2>&1)
# possible responses:
# secrets-store-csi-driver" has been removed from your repositories
# Error: no repo named "secrets-store-csi-driver" found

if [[ $response == *"has been removed from your repositories"* ]]; then
  echo "Successfully removed secrets-store-csi-driver Helm repository."
elif [[ $response == *'no repo named "secrets-store-csi-driver" found'* ]]; then
  echo "secrets-store-csi-driver Helm repository has already been removed."
else
  echo "$response"
  echo "Failed to remove secrets-store-csi-driver Helm repository. Exiting..."
  exit 1
fi

response=$(helm repo remove aws-secrets-manager 2>&1)
# possible responses:
# aws-secrets-manager" has been removed from your repositories
# Error: no repo named "aws-secrets-manager" found

if [[ $response == *"has been removed from your repositories"* ]]; then
  echo "Successfully removed aws-secrets-manager Helm repository."
elif [[ $response == *'no repo named "aws-secrets-manager" found'* ]]; then
  echo "aws-secrets-manager Helm repository has already been removed."
else
  echo "$response"
  echo "Failed to remove aws-secrets-manager Helm repository. Exiting..."
  exit 1
fi

response=$(helm uninstall -n kube-system csi-secrets-store 2>&1)
# possible responses:
# release "csi-secrets-store" uninstalled
# Error: uninstall: Release not loaded: csi-secrets-store: release: not found

if [[ $response == *"uninstalled"* ]]; then
  echo "Successfully removed csi-secrets-store Helm chart."
elif [[ $response == *'release: not found'* ]]; then
  echo "csi-secrets-store Helm chart has already been removed."
else
  echo "$response"
  echo "Failed to remove csi-secrets-store Helm chart. Exiting..."
  exit 1
fi

response=$(helm uninstall -n kube-system secrets-provider-aws 2>&1)
# possible responses:
# release "secrets-provider-aws" uninstalled
# Error: uninstall: Release not loaded: secrets-provider-aws: release: not found

if [[ $response == *"uninstalled"* ]]; then
  echo "Successfully removed secrets-provider-aws Helm chart."
elif [[ $response == *'release: not found'* ]]; then
  echo "secrets-provider-aws Helm chart has already been removed."
else
  echo "$response"
  echo "Failed to remove secrets-provider-aws Helm chart. Exiting..."
  exit 1
fi

response=$(kubectl delete sa/xkops-secret-sa --namespace xkops 2>&1)
# possible responses:
# serviceaccount "xkops-secret-sa" deleted
# Error from server (NotFound): serviceaccounts "xkops-secret-sa" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully deleted xkops-secret-sa service account."
elif [[ $response == *"Error from server (NotFound)"*  ]]; then
  echo "xkops-secret-sa service account has already been removed."
else
  echo "$response"
  echo "Failed to remove xkops-secret-sa service account. Exiting..."
  exit 1
fi

