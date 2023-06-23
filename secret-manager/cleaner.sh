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

response=$(helm uninstall xkops 2>&1)
# possible responses:
# release "xkops" uninstalled
# Error: uninstall: Release not loaded: xkops: release: not found

if [[ $response == *"uninstalled"* ]]; then
  echo "Successfully removed XkOps from your cluster."
elif [[ $response == *'release: not found'* ]]; then
  echo "XkOps has already been removed."
else
  echo "$response"
  echo "Failed to remove XkOps from your cluster. Exiting..."
  exit 1
fi

response=$(helm repo remove secrets-store-csi-driver 2>&1)
# possible responses:
# secrets-store-csi-driver" has been removed from your repositories
# Error: no repo named "secrets-store-csi-driver" found

if [[ $response == *"has been removed from your repositories"* ]]; then
  echo "Successfully removed secrets-store-csi-driver Helm repository."
elif [[ $response == *'Error: no repo named'* ]]; then
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
elif [[ $response == *'Error: no repo named'* ]]; then
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
  echo "Successfully deleted xkops-secret-sa service account from the cluster."
elif [[ $response == *"Error from server (NotFound)"*  ]]; then
  echo "xkops-secret-sa service account has already been removed from the cluster."
else
  echo "$response"
  echo "Failed to remove xkops-secret-sa service account from the cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment xkops-deployment -n xkops 2>&1)
# possible responses:
# deployment.apps "xkops-deployment" deleted
# Error from server (NotFound): deployments.apps "xkops-deployment" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed xkops-deployment deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "xkops-deployment deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove xkops-deployment deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment xkops-dashboard -n xkops 2>&1)
# possible responses:
# deployment.apps "xkops-dashboard" deleted
# Error from server (NotFound): deployments.apps "xkops-dashboard" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed xkops-dashboard deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "xkops-dashboard deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove xkops-dashboard deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete pods -n xkops --all --grace-period 0 --force 2>&1)
# possible responses:
# pod "pod-name" force deleted <--- for all pods
# No resources found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed all xkops pods from your cluster."
elif [[ $response == *"No resources found"* ]]; then
  echo "All xkops pods has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove all xkops pods from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete namespace xkops 2>&1)
# possible responses:
# namespace "xkops" deleted
# Error from server (NotFound): namespaces "xkops" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed xkops namespace from your cluster."
elif [[ $response == *'Error from server (NotFound): namespaces'* ]]; then
  echo "xkops namespace has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove xkops namespace from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment robusta-forwarder -n robusta 2>&1)
# possible responses:
# deployment.apps "robusta-forwarder" deleted
# Error from server (NotFound): deployments.apps "robusta-forwarder" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed robusta-forwarder deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "robusta-forwarder deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove robusta-forwarder deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment robusta-runner -n robusta 2>&1)
# possible responses:
# deployment.apps "robusta-runner" deleted
# Error from server (NotFound): deployments.apps "robusta-runner" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed robusta-runner deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "robusta-runner deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove robusta-runner deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete namespace robusta 2>&1)
# possible responses:
# namespace "robusta" deleted
# Error from server (NotFound): namespaces "robusta" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed robusta namespace from your cluster."
elif [[ $response == *'Error from server (NotFound): namespaces'* ]]; then
  echo "robusta namespace has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove robusta namespace from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment kubecost-cost-analyzer -n kubecost 2>&1)
# possible responses:
# deployment.apps "kubecost-cost-analyzer" deleted
# Error from server (NotFound): deployments.apps "kubecost-cost-analyzer" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed kubecost-cost-analyzer deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "kubecost-cost-analyzer deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove kubecost-cost-analyzer deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete deployment kubecost-grafana -n kubecost 2>&1)
# possible responses:
# deployment.apps "kubecost-grafana" deleted
# Error from server (NotFound): deployments.apps "kubecost-grafana" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed kubecost-grafana deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "kubecost-grafana deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove kubecost-grafana deployment from your cluster. Exiting..."
  exit 1
fi
response=$(kubectl delete deployment kubecost-kube-state-metrics -n kubecost 2>&1)
# possible responses:
# deployment.apps "kubecost-kube-state-metrics" deleted
# Error from server (NotFound): deployments.apps "kubecost-kube-state-metrics" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed kubecost-kube-state-metrics deployment from your cluster."
elif [[ $response == *'Error from server (NotFound): deployments.apps'* ]]; then
  echo "kubecost-kube-state-metrics deployment has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove kubecost-kube-state-metrics deployment from your cluster. Exiting..."
  exit 1
fi

response=$(kubectl delete namespace kubecost 2>&1)
# possible responses:
# namespace "kubecost" deleted
# Error from server (NotFound): namespaces "kubecost" not found

if [[ $response == *"deleted"* ]]; then
  echo "Successfully removed kubecost namespace from your cluster."
elif [[ $response == *'Error from server (NotFound): namespaces'* ]]; then
  echo "kubecost namespace has already been removed from your cluster."
else
  echo "$response"
  echo "Failed to remove kubecost namespace from your cluster. Exiting..."
  exit 1
fi

#https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudformation/describe-stacks.html
response=$(aws cloudformation describe-stacks --stack-name eksctl-xkops-cluster-addon-iamserviceaccount-xkops-xkops-secret-sa 2>&1)
# possible responses:
# The output shows the stack information but we only need to check the stack name
# "StackName": "eksctl-xkops-cluster-addon-iamserviceaccount-xkops-xkops-secret-sa"
# An error occurred (ValidationError) when calling the DescribeStacks operation: Stack with id eksctl-xkops-cluster-addon-iamserviceaccount-xkops-xkops-secret-sa does not exist

if [[ $response == *'"StackName": "eksctl-xkops-cluster-addon-iamserviceaccount-xkops-xkops-secret-sa"'* ]]; then
  # Refernce : https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-deleting-stack.html
  aws cloudformation delete-stack --stack-name eksctl-xkops-cluster-addon-iamserviceaccount-xkops-xkops-secret-sa
  echo "Successfully deleted xkops-secret-sa stack."
elif [[ $response == *"does not exist"*  ]]; then
  echo "xkops-secret-sa stack has already been removed."
else
  echo "$response"
  echo "Failed to remove xkops-secret-sa stack. Exiting..."
  exit 1
fi

# Refernce : https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html
response=$(eksctl delete addon --cluster xkops-cluster --name aws-ebs-csi-driver 2>&1)
# possible responses:
# deleted addon: aws-ebs-csi-driver

if [[ $response == *"deleted addon:"* ]]; then
  echo "Successfully deleted aws-ebs-csi-driver addon."
elif [[ $response == *"does not exist"*  ]]; then
  echo "aws-ebs-csi-driver addon has already been removed."
else
  echo "$response"
  echo "Failed to remove aws-ebs-csi-driver addon. Exiting..."
  exit 1
fi


# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/list-attached-role-policies.html
response=$(aws iam list-attached-role-policies --role-name XkOps-EBS-iam-role 2>&1)
# possible responses:
# The response shows the detailes of the policy, we only need the PolicyName to confirm it exists.
# "PolicyName": "AmazonEBSCSIDriverPolicy"
# "AttachedPolicies": []
# An error occurred (NoSuchEntity) when calling the ListAttachedRolePolicies operation: The role with name XkOps-EBS-iam-role cannot be found.

if [[ $response == *'"PolicyName": "AmazonEBSCSIDriverPolicy"'* ]]; then
  # Refernce : https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/detach-role-policy.html
  aws iam detach-role-policy --role-name XkOps-EBS-iam-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
  response2=$(aws iam list-attached-role-policies --role-name XkOps-EBS-iam-role 2>&1)
  if [[ $response2 == *'"AttachedPolicies": []'* ]]; then
    echo "Successfully detached the AmazonEBSCSIDriverPolicy."
  fi
elif [[ $response == *'"AttachedPolicies": []'*  ]]; then
  echo "AmazonEBSCSIDriverPolicy has already been detached."
elif [[ $response == *"The role with name XkOps-EBS-iam-role cannot be found"*  ]]; then
  echo "AmazonEBSCSIDriverPolicy has already been detached."
else
  echo "$response"
  echo "Failed to detach the AmazonEBSCSIDriverPolicy. Exiting..."
  exit 1
fi


#https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/get-role.html
response=$(aws iam get-role --role-name XkOps-EBS-iam-role 2>&1)
# possible responses:
# The response shows details of the role, we only need the RoleName to confirm it exists.
# "RoleName": "XkOps-EBS-iam-role"
# An error occurred (NoSuchEntity) when calling the GetRole operation: The role with name XkOps-EBS-iam-role cannot be found.
# An error occurred (DeleteConflict) when calling the DeleteRole operation: Cannot delete entity, must detach all policies first.

if [[ $response == *'"RoleName": "XkOps-EBS-iam-role"'* ]]; then
  # Refernce : https://awscli.amazonaws.com/v2/documentation/api/latest/reference/iam/delete-role.html
  aws iam delete-role --role-name XkOps-EBS-iam-role 
  response2=$(aws iam get-role --role-name XkOps-EBS-iam-role 2>&1)
  if [[ $response2 == *"cannot be found."* ]]; then
    echo "Successfully deleted the XkOps-EBS-iam-role."
  fi
elif [[ $response == *"cannot be found."*  ]]; then
  echo "XkOps-EBS-iam-role has already been removed."
elif [[ $response == *"must detach all policies first."*  ]]; then
  echo "Error in detaching the policies associated with the role. Cannot delete role without detaching associated policies."
  exit 1
else
  echo "$response"
  echo "Failed to remove XkOps-EBS-iam-role. Exiting..."
  exit 1
fi


