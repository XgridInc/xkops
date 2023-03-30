#!/bin/bash

helm repo remove secrets-store-csi-driver
helm repo remove aws-secrets-manager
helm uninstall -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set syncSecret.enabled=true --version 1.2.4
helm uninstall -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws
