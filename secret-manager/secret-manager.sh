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

# Add the Secrets Store CSI Driver Helm repository
if helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts >/dev/null 2>&1; then
  echo "Successfully added secrets-store-csi-driver Helm repository"
else
  echo "Failed to add secrets-store-csi-driver Helm repository"
fi

# Install the Secrets Store CSI Driver
if helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set syncSecret.enabled=true --version 1.2.4 >/dev/null 2>&1; then
  echo "Successfully installed Secrets Store CSI Driver"
else
  echo "Failed to install Secrets Store CSI Driver"
fi

# Add the AWS Secrets Manager CSI Driver Helm repository
if helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws >/dev/null 2>&1; then
  echo "Successfully added aws-secrets-manager Helm repository"
else
  echo "Failed to add aws-secrets-manager Helm repository"
fi

# Install the AWS Secrets Manager CSI Driver
if helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws >/dev/null 2>&1; then
  echo "Successfully installed AWS Secrets Manager CSI Driver"
else
  echo "Failed to install AWS Secrets Manager CSI Driver"
fi

# Prompt the user to enter the values for the variables
echo "Enter the cluster region: "
read -r region

# Create the secret in the AWS Secrets Manager
if ! aws --region "$region" secretsmanager  create-secret --name xkops-my-secret --secret-string '{"AWS_ACCESS_KEY_ID":"<aws-access-key-id>", "AWS_SECRET_ACCESS_KEY":"<aws-secret-access-key>","AWS_SESSION_TOKEN":"<aws-session-token>","ROBUSTA_UI_API_KEY":"<robusta-ui-api-key>","SLACK_API_KEY":"<slack-api-key>","PX_API_KEY":"<pixie-api-key>","PX_DEPLOY_KEY":"<pixie-deploy-key>"}'  &> /dev/null; then
  echo "Failed to create secret in AWS Secrets Manager"
  exit 1
fi

secret_arn=$(aws secretsmanager describe-secret --secret-id xkops-my-secret --query ARN --output text)

# Create a policy for the secret
if ! aws --region "$region" --query Policy.Arn --output text iam create-policy --policy-name xkops-creds-secret-policy --policy-document '{     "Version": "2012-10-17",     "Statement": [ {         "Effect": "Allow",         "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "sts:AssumeRoleWithWebIdentity"],         "Resource": ["'"$secret_arn"'"]     } ] }'; then
  echo "Failed to create policy for the secret"
  exit 1
fi

policy_arn=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='xkops-creds-secret-policy'].Arn" --output text)

# Prompt the user to enter the values for the variables
echo "Enter the Cluster Name: "
read -r cluster_name

# Associate the IAM OIDC provider with the EKS cluster
if ! eksctl utils associate-iam-oidc-provider --region="$region" --cluster="$cluster_name" --approve; then
  echo "Failed to associate IAM OIDC provider with EKS cluster"
  exit 1
fi

# Create an IAM service account for the secret
if ! eksctl create iamserviceaccount --name xkops-my-secret-sa --namespace xkops --region="$region" --cluster "$cluster_name" --attach-policy-arn "$policy_arn" --approve --override-existing-serviceaccounts; then
  echo "Failed to create IAM service account for the secret"
  exit 1
fi

# Apply the secret provider class YAML file
if ! kubectl apply -f ./secretproviderclass.yaml; then
  echo "Failed to apply secret provider class YAML file"
  exit 1
fi
