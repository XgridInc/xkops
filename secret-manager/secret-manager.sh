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

response=$(helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts 2>&1)

# possible responses:
# Helm repo added: "secrets-store-csi-driver" has been added to your repositories
# Helm repo already added: "secrets-store-csi-driver" already exists with the same configuration, skipping

if [[ $response == *"has been added to your repositories"* ]]; then
  echo "Successfully added secrets-store-csi-driver Helm repository."
elif [[ $response == *"already exists with the same configuration, skipping"* ]]; then
  echo "secrets-store-csi-driver Helm repository have already been added."
else
  echo "$response"
  echo "Failed to add secrets-store-csi-driver Helm repository. Exiting..."
  exit 1
fi

response=$(helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set syncSecret.enabled=true --version 1.2.4 2>&1)

# possible responses:
# Kubernetes cluster unreachable: Error: INSTALLATION FAILED: Kubernetes cluster unreachable: the server has asked for the client to provide credentials
# Already installed: Error: INSTALLATION FAILED: cannot re-use a name that is still in use
# Successfull Install:-
# ---------------
# NAME: csi-secrets-store
# LAST DEPLOYED: Thu May 18 17:16:49 2023
# NAMESPACE: kube-system
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
# NOTES:
# The Secrets Store CSI Driver is getting deployed to your cluster.

# To verify that Secrets Store CSI Driver has started, run:

#   kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"

# Now you can follow these steps https://secrets-store-csi-driver.sigs.k8s.io/getting-started/usage.html
# to create a SecretProviderClass resource, and a deployment using the SecretProviderClass.
# ---------------

if [[ $response == *"STATUS: deployed"* ]]; then
  echo "Successfully installed Secrets Store CSI Driver."
elif [[ $response == *"Kubernetes cluster unreachable"* ]]; then
  echo "Kubernetes cluster unreachable. Exiting..."
  exit 1
elif [[ $response == *"cannot re-use a name that is still in use"* ]]; then
  echo "Secrets Store CSI Driver already installed."
else
  echo "$response"
  echo "Failed to install Secrets Store CSI Driver. Exiting..."
  exit 1
fi

response=$(helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws 2>&1)

# possible responses:
# Helm repo added: "aws-secrets-manager" has been added to your repositories
# Helm repo already added: "aws-secrets-manager" already exists with the same configuration, skipping

if [[ $response == *"has been added to your repositories"* ]]; then
  echo "Successfully added aws-secrets-manager Helm repository."
elif [[ $response == *"already exists with the same configuration, skipping"* ]]; then
  echo "aws-secrets-manager Helm repository have already been added."
else
  echo "$response"
  echo "Failed to add aws-secrets-manager Helm repository. Exiting..."
  exit 1
fi

response=$(helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws 2>&1)

# possible responses:
# Kubernetes cluster unreachable: Error: INSTALLATION FAILED: Kubernetes cluster unreachable: the server has asked for the client to provide credentials
# Already installed: Error: INSTALLATION FAILED: cannot re-use a name that is still in use
# Successfull Install:-
# ---------------
# NAME: secrets-provider-aws
# LAST DEPLOYED: Thu May 18 18:30:50 2023
# NAMESPACE: kube-system
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
# ---------------

if [[ $response == *"STATUS: deployed"* ]]; then
  echo "Successfully installed AWS Secrets Manager CSI Driver."
elif [[ $response == *"Kubernetes cluster unreachable"* ]]; then
  echo "Kubernetes cluster unreachable. Exiting..."
  exit 1
elif [[ $response == *"cannot re-use a name that is still in use"* ]]; then
  echo "AWS Secrets Manager CSI Driver already installed."
else
  echo "$response"
  echo "Failed to install AWS Secrets Manager CSI Driver. Exiting..."
  exit 1
fi

# Prompt the user to enter the values for the variables
echo "Enter the EKS cluster region: "
read -r region

# Create the secret in the AWS Secrets Manager
response=$(aws --region "$region" secretsmanager create-secret --name xkops-secret --secret-string '{"AWS_ACCESS_KEY_ID":"<aws-access-key-id>", "AWS_SECRET_ACCESS_KEY":"<aws-secret-access-key>","AWS_SESSION_TOKEN":"<aws-session-token>","ROBUSTA_UI_API_KEY":"<robusta-ui-api-key>","SLACK_API_KEY":"<slack-api-key>","PX_API_KEY":"<pixie-api-key>","PX_DEPLOY_KEY":"<pixie-deploy-key>"}' 2>&1)

# possible responses:
# Secret created:
# {
#     "ARN": "arn:aws:secretsmanager:ap-southeast-1:[AWS-ACCOUNT-NUMBER]:secret:test1-Se57FI",
#     "Name": "test1",
#     "VersionId": "a42fc663-c76f-44de-bce8-bd43da62bba0"
# }
# Secret already created: An error occurred (ResourceExistsException) when calling the CreateSecret operation: The operation failed because the secret xkops-secret already exists.
# Secret scheduled for deletion: An error occurred (InvalidRequestException) when calling the CreateSecret operation: You can't create this secret because a secret with this name is already scheduled for deletion.

if [[ $response == *"\"ARN\":"* ]]; then
  echo "xkops-secret created in AWS Secret Manager."
elif [[ $response == *"already exists"* ]]; then
  echo "xkops-secret already exists in AWS Secret Manager."
elif [[ $response == *"scheduled for deletion."* ]]; then
  echo "xkops-secret scheduled for deletion in AWS Secret Manager. Exiting..."
  exit 1
else
  echo "$response"
  echo "Failed to create xkops-secret in AWS Secrets Manager. Exiting..."
  exit 1
fi

#Fetch ARN of xkops-secret
response=$(aws --region "$region" secretsmanager describe-secret --secret-id xkops-secret --query ARN --output text 2>&1)

# possible responses:
# Secret ARN fetched: arn:aws:secretsmanager:ap-southeast-1:[AWS-ACCOUNT-NUMBER]:secret:xkops-secret-LlOZro
# Secret doesn't exist: An error occurred (ResourceNotFoundException) when calling the DescribeSecret operation: Secrets Manager can't find the specified secret.
# Invalid Session Token/Access Key: An error occurred (UnrecognizedClientException) when calling the DescribeSecret operation: The security token included in the request is invalid
# Invalid Secret Access Key: An error occurred (InvalidSignatureException) when calling the DescribeSecret operation: The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method. Consult the service documentation for details.

if [[ $response == *"arn:"* ]]; then
  echo "xkops-secret ARN fetched."
  secret_arn=$response
elif [[ $response == *"can't find the specified secret"* ]]; then
  echo "ARN can't be fetched because secret does no exist. Exiting..."
  exit 1
elif [[ $response == *"security token included in the request is invalid"* ]]; then
  echo "Invalid Session Token or Access Key ID. Exiting..."
  exit 1
elif [[ $response == *"Check your AWS Secret Access Key and signing method"* ]]; then
  echo "Invalid Secret Access Key. Exiting..."
  exit 1
else
  echo "$response"
  echo "Failed to fetch ARN. Exiting..."
  exit 1
fi

# Create a policy for the secret
response=$(aws --region "$region" --query Policy.Arn --output text iam create-policy --policy-name xkops-secret-policy --policy-document '{     "Version": "2012-10-17",     "Statement": [ {         "Effect": "Allow",         "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "sts:AssumeRoleWithWebIdentity"],         "Resource": ["'"$secret_arn"'"]     } ] }' 2>&1)
# possible responses:
# Policy created: arn:aws:iam::[AWS-ACCOUNT-NUMBER]:policy/xkops-secret-policy
# Policy already exist: An error occurred (EntityAlreadyExists) when calling the CreatePolicy operation: A policy called xkops-secret-policy already exists. Duplicate names are not allowed.

if [[ $response == *"arn:"* ]]; then
  echo "xkops-secret-policy is created."
elif [[ $response == *"Duplicate names are not allowed"* ]]; then
  echo "A policy named xkops-secret-policy is already created."
else
  echo "$response"
  echo "Failed to create policy \"xkops-secret-policy\". Exiting..."
  exit 1
fi

#Fetch ARN of policy created
response=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='xkops-secret-policy'].Arn" --output text 2>&1)
# possible responses:
# Policy ARN fetched: arn:aws:iam::[AWS-ACCOUNT-NUMBER]:policy/xkops-secret-policy

if [[ $response == *"arn:"* ]]; then
  echo "xkops-secret-policy ARN fetched."
  policy_arn=$response
elif [[ $response == *"security token included in the request is invalid"* ]]; then
  echo "Invalid Session Token or Access Key ID. Exiting..."
  exit 1
elif [[ $response == *"Check your AWS Secret Access Key and signing method"* ]]; then
  echo "Invalid Secret Access Key. Exiting..."
  exit 1
else
  echo "$response"
  echo "Failed to fetch ARN. Exiting..."
  exit 1
fi


# Prompt the user to enter the values for the variables
echo "Enter the EKS cluster name: "
read -r cluster_name

# Associate the IAM OIDC provider with the EKS cluster
response=$(eksctl utils associate-iam-oidc-provider --region="$region" --cluster="$cluster_name" --approve)

# possible responses:
# [ℹ] IAM Open ID Connect provider is already associated with cluster "xkops-cluster" in "ap-southeast-1"
# will create IAM Open ID Connect provider for cluster "xkops-cluster" in "ap-southeast-1" [✔] created IAM Open ID Connect provider for cluster "xkops-cluster" in "ap-southeast-1"



if [[ $response == *"is already associated with cluster"* ]]; then
  echo "IAM Open ID Connect provider already associated with cluster"

elif [[ $response == *"created IAM Open ID Connect provider for cluster"* ]]; then
  echo "IAM Open ID Connect provider associated with cluster"
else
  echo "$response"
  echo "Failed to create IAM Open ID Connect provider. Exiting..."
  exit 1
fi


# Create an IAM service account for the secret
response=$(eksctl create iamserviceaccount --name xkops-secret-sa --namespace xkops --region="$region" --cluster "$cluster_name" --attach-policy-arn "$policy_arn" --approve --override-existing-serviceaccounts)



#possible responses
# created serviceaccount "xkops/xkops-secret-sa"
# 1 existing iamserviceaccount(s) (xkops/xkops-secret-sa) will be excluded

if [[ $response == *"created serviceaccount"* ]]; then
  echo "Serviceaccount created in xkops namespace"
elif [[ $response == *"existing iamserviceaccount(s)"* ]]; then
  echo "Serviceaccount stack already exists"
else
  echo "$response"
  echo "Failed to create service account. Exiting..."
  exit 1
fi
