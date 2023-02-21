# Use an official Terraform image as the base
FROM hashicorp/terraform:light

# Copy the Terraform script into the container
COPY ebs-provisioning.tf .

# Initialize Terraform and download the required provider
RUN terraform init
