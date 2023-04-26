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

# This is a cleaner script for secret manager automation.
# It removes all the installed dependencies for setting up secret manager.
helm repo remove secrets-store-csi-driver
helm repo remove aws-secrets-manager
helm uninstall -n kube-system csi-secrets-store
helm uninstall -n kube-system secrets-provider-aws
kubectl delete sa/xkops-secret-sa --namespace xkops 
