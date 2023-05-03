#!/bin/bash

# Remove the secrets-store-csi-driver Helm repository
if helm repo remove secrets-store-csi-driver >/dev/null 2>&1; then
  echo "Successfully removed secrets-store-csi-driver Helm repository"
else
  echo "Failed to remove secrets-store-csi-driver Helm repository"
fi

# Remove the aws-secrets-manager Helm repository
if helm repo remove aws-secrets-manager >/dev/null 2>&1; then
  echo "Successfully removed aws-secrets-manager Helm repository"
else
  echo "Failed to remove aws-secrets-manager Helm repository"
fi

# Uninstall the csi-secrets-store Helm chart from the kube-system namespace
if helm uninstall -n kube-system csi-secrets-store >/dev/null 2>&1; then
  echo "Successfully uninstalled csi-secrets-store Helm chart"
else
  echo "Failed to uninstall csi-secrets-store Helm chart"
fi

# Uninstall the secrets-provider-aws Helm chart from the kube-system namespace
if helm uninstall -n kube-system secrets-provider-aws >/dev/null 2>&1; then
  echo "Successfully uninstalled secrets-provider-aws Helm chart"
else
  echo "Failed to uninstall secrets-provider-aws Helm chart"
fi

# Delete the xkops-secret-sa service account from the xkops namespace
if kubectl delete sa/xkops-secret-sa --namespace xkops >/dev/null 2>&1; then
  echo "Successfully deleted xkops-secret-sa service account"
else
  echo "Failed to delete xkops-secret-sa service account"
fi
