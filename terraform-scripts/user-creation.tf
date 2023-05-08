# Declare the AWS provider with the region
provider "aws" {
  region = "ap-southeast-1" # Change this to the region you prefer
}

# Create an AWS IAM user named "XkOps_user"
resource "aws_iam_user" "XkOps_user" {
  name = "XkOps_user"
}

# Create an IAM user policy named "XkOps-user-policy" and attach it to the "XkOps_user" user
resource "aws_iam_user_policy" "XkOps_user_policy" {
  name = "XkOps-user-policy"
  user = aws_iam_user.XkOps_user.name

  # Define the policy in JSON format
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # List of AWS actions that are allowed by this policy
          "cloudformation:ListStacks",
          "cloudformation:CreateStack",
          "cloudformation:GetStackPolicy",
          "cloudformation:DescribeStacks",
          "cloudformation:ListStackResources",
          "iam:CreatePolicy",
          "iam:GetOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:DetachRolePolicy",
          "iam:AttachRolePolicy",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:ListOpenIDConnectProviders",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:PassRole",
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DescribeVolumes",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:TagResource",
          "eks:CreateAddon",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:DescribeAddonConfiguration",
          "eks:DescribeAddonVersions",
          "secretsmanager:CreateSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:PutSecretValue"
        ]
        Resource = "*" # Allow actions on any AWS resource
      }
    ]
  })
}