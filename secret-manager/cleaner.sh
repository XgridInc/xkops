#!/bin/bash

helm repo remove secrets-store-csi-driver
helm repo remove aws-secrets-manager
helm uninstall -n kube-system csi-secrets-store
helm uninstall -n kube-system secrets-provider-aws
