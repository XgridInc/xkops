#!/bin/bash

# Add the Secrets Store CSI Driver Helm repository
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

# Install the Secrets Store CSI Driver
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set syncSecret.enabled=true --version 1.2.4

# Add the AWS Secrets Manager CSI Driver Helm repository
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws

# Install the AWS Secrets Manager CSI Driver
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws

# Prompt the user to enter the values for the variables
read -p "Enter the cluster region: " region
read -p "Enter the name of the secret: " secret_name
read -p "Enter the AWS access key ID: " access_key_id
read -p "Enter the AWS secret access key: " secret_access_key
read -p "Enter the AWS session token: " session_token
read -p "Enter the Robusta UI API key: " robusta_ui_api_key
read -p "Enter the Slack API key: " slack_api_key
read -p "Enter the Pixie API key: " pixie_api_key
read -p "Enter the Pixie deploy key: " pixie_deploy_key

# Create the secret in the AWS Secrets Manager
aws --region "$region" secretsmanager create-secret \
    --name "$secret_name" \
    --secret-string '{"AWS_ACCESS_KEY_ID":"'"$access_key_id"'", "AWS_SECRET_ACCESS_KEY":"'"$secret_access_key"'","AWS_SESSION_TOKEN":"'"$session_token"'","ROBUSTA_UI_API_KEY":"'"$robusta_ui_api_key"'","SLACK_API_KEY":"'"$slack_api_key"'","PX_API_KEY":"'"$pixie_api_key"'","PX_DEPLOY_KEY":"'"$pixie_deploy_key"'"}'

# Prompt the user to enter the values for the variables
read -p "Enter the name of the IAM policy: " policy_name
read -p "Enter the ARN of the secret: " secret_arn

aws --region "$region" --query Policy.Arn --output text iam create-policy --policy-name "$policy_name" --policy-document '{     "Version": "2012-10-17",     "Statement": [ {         "Effect": "Allow",         "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "sts:AssumeRoleWithWebIdentity"],         "Resource": ["'"$secret_arn"'"]     } ] }'

# Associate the IAM OIDC provider with the EKS cluster
eksctl utils associate-iam-oidc-provider --region="$region" --cluster="$cluster_name" --approve

# Prompt the user to enter the values for the variables
read -p "Enter the name of the Service Account : " sa_name
read -p "Enter the Policy ARN: " policy_arn

eksctl create iamserviceaccount --name "$sa_name" --namespace xkops --region="$region" --cluster "$cluster_name" --attach-policy-arn "$policy_arn" --approve --override-existing-serviceaccounts
