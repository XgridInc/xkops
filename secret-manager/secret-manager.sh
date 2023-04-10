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
echo "Enter the cluster region: "
read -r region

# Create the secret in the AWS Secrets Manager
aws --region "$region" secretsmanager  create-secret --name secret-xkops --secret-string '{"AWS_ACCESS_KEY_ID":"<aws-access-key-id>", "AWS_SECRET_ACCESS_KEY":"<aws-secret-access-key>","AWS_SESSION_TOKEN":"<aws-session-token>","ROBUSTA_UI_API_KEY":"<robusta-ui-api-key>","SLACK_API_KEY":"<slack-api-key>","PX_API_KEY":"<pixie-api-key>","PX_DEPLOY_KEY":"<pixie-deploy-key>"}'  &> /dev/null
secret_arn=$(aws secretsmanager describe-secret --secret-id secret-xkops --query ARN --output text)
#Print Secret ARN
#echo "Secret ARN: $secret_arn"

aws --region "$region" --query Policy.Arn --output text iam create-policy --policy-name xkops-creds-secret-policy --policy-document '{     "Version": "2012-10-17",     "Statement": [ {         "Effect": "Allow",         "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "sts:AssumeRoleWithWebIdentity"],         "Resource": ["'"$secret_arn"'"]     } ] }' 
policy_arn=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='xkops-creds-secret-policy'].Arn" --output text)

#Print Policy ARN
#echo "The policy ARN is: $policy_arn"

# Prompt the user to enter the values for the variables
echo "Enter the Cluster Name: "
read -r cluster_name

# Associate the IAM OIDC provider with the EKS cluster
eksctl utils associate-iam-oidc-provider --region="$region" --cluster="$cluster_name" --approve

eksctl create iamserviceaccount --name xkops-secret-sa --namespace xkops --region="$region" --cluster "$cluster_name" --attach-policy-arn "$policy_arn" --approve --override-existing-serviceaccounts

kubectl apply -f ./secretproviderclass.yaml