#!/bin/bash 

#pixie namespace
export OLMNS="olm"
export PXOPNS="px-operator"
export PLNS="pl"
export PX_NAMESPACES=("olm" "pl" "px-operator")

#pl deployments
export PL_KELVIN="kelvin"
export PL_CLOUD_CONNECTOR="vizier-cloud-connector"
export PL_VIZIER_QUERY_BROKER="vizier-query-broker"

#olm deployments
export OLM_CATALOG_OPERATOR="catalog-operator"
export OLM_OPERATOR="olm-operator"

#pixie keys
export PX_API_KEY=$PX_API_KEY
export PX_DEPLOY_KEY=$PX_DEPLOY_KEY


