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

#pixie namespace
export OLMNS="olm"
export PXOPNS="px-operator"
export PLNS="pl"
export PX_NAMESPACES=("olm" "pl" "px-operator")
export PX_TEST_NS=xkops-testing

#pl deployments
export PL_KELVIN="kelvin"
export PL_CLOUD_CONNECTOR="vizier-cloud-connector"
export PL_VIZIER_QUERY_BROKER="vizier-query-broker"

#olm deployments
export OLM_CATALOG_OPERATOR="catalog-operator"
export OLM_OPERATOR="olm-operator"

#pixie pods
export TEST_POD=xkops-test-pod

#pixie keys
export PX_API_KEY=$PX_API_KEY
export PX_DEPLOY_KEY=$PX_DEPLOY_KEY


