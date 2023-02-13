#!/bin/bash
source /src/config/config.sh

# Kubecost deployment name and image name
export KC_IMAGE="gcr.io/kubecost1/cost-model"
export KC_DEPLOYMENT="kubecost"
export KC_NAMESPACE=("kubecost")
