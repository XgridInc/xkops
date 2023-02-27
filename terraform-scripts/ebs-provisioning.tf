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

# Defined variables for region name and cluster name to be used by terraform script
variable "region" {
  type = string
}
variable "cluster_name" {
  type = string
}
# The AWS provider is used to interact with resources in an AWS account, such as creating and managing EC2 instances.
provider "aws" {
  region = var.region
}

# Cluster name for terraform scripts to be run on
data "aws_eks_cluster" "Eks_cluster" {
  # name = "xgrid-website-migration"
  name=var.cluster_name
}

# TLS Certificate for OIDC provider
data "tls_certificate" "XkOps" {
  url = data.aws_eks_cluster.Eks_cluster.identity[0].oidc[0].issuer
}

# Adds OIDC provider associated with the given cluster above 
resource "aws_iam_openid_connect_provider" "Eks_cluster_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.XkOps.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.Eks_cluster.identity[0].oidc[0].issuer
}

# Creates IAM Role with trust relationship set as ebs-csi-controller-sa
resource "aws_iam_role" "eks_cluster" {
  name = "XkOps-EBS-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.Eks_cluster_oidc_provider.arn
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

# Adds Amazon EBS CSI Driver add-on in the EKS cluster given above
resource "aws_eks_addon" "ebs_csi" {
  addon_name               = "aws-ebs-csi-driver"
  cluster_name             = data.aws_eks_cluster.Eks_cluster.name
  service_account_role_arn = aws_iam_role.eks_cluster.arn
}
