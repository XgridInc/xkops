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

# This code is written in Terraform and is used to specify the version of the AWS provider that will be used. The source of the provider is "hashicorp/aws" and the version must be 4.0 or higher.
terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

# The AWS provider is used to interact with resources in an AWS account, such as creating and managing EC2 instances.
# var is used here to pick the region value from environment which will be feeded through input values in helm.
variable "REGION" {
  type = string
}
variable "CLUSTER_NAME" {
  type = string
}
provider "aws" {
  region = var.REGION
}

# Cluster name for terraform scripts to be run on
data "aws_eks_cluster" "Eks_cluster" {
  name=var.CLUSTER_NAME
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.Eks_cluster.identity[0].oidc[0].issuer
}

locals {
   eks_oidc_provider = data.aws_iam_openid_connect_provider.eks
}

# Creates IAM Role with trust relationship set as ebs-csi-controller-sa
resource "aws_iam_role" "eks_cluster" {
  name = "XkOps-EBS-iam-role"
  # Adds trust relationship in the role with ebs-csi-controller service account
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated =  local.eks_oidc_provider.arn
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.Eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(data.aws_eks_cluster.Eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attaches AmazonEBSCSIDriverPolicy to above created IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_ebs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Adds Amazon EBS CSI Driver add-on in the existing EKS cluster provided above
resource "aws_eks_addon" "ebs_csi" {
  addon_name               = "aws-ebs-csi-driver"
  cluster_name             = data.aws_eks_cluster.Eks_cluster.name
  service_account_role_arn = aws_iam_role.eks_cluster.arn
}
