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

import json
import subprocess

import boto3


def test_iam_role_creation():
    """
    Test if the IAM role is created by Terraform.

    The test uses Boto3 to check if the IAM role with the given name exists. If the IAM role exists,
    the test passes. If the IAM role does not exist, the test fails.

    Raises:
        AssertionError: If the IAM role with the given name does not exist.
    """
    iamClient = boto3.client("iam")
    roleName = "XkOps-EBS-iam-role"
    try:
        roleResponse = iamClient.get_role(RoleName=roleName)
        assert roleResponse["Role"]["RoleName"] == roleName
    except iamClient.exceptions.NoSuchEntityException:
        assert False, f"IAM role {roleName} does not exist"


def test_iam_policy_attachment():
    """
    Test if the IAM policy is attached to the IAM role created by Terraform.

    The test uses Boto3 to check if the IAM role with the given name has the expected policy attached.
    If the IAM role has the expected policy attached, the test passes. If the IAM role does not have
    the expected policy attached, the test fails.

    Raises:
        AssertionError: If the IAM role does not have the expected policy attached.
    """
    iamClient = boto3.client("iam")
    roleName = "XkOps-EBS-iam-role"
    policyArn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    attachedPoliciesResponse = iamClient.list_attached_role_policies(
        RoleName=roleName
    )
    for policy in attachedPoliciesResponse["AttachedPolicies"]:
        if policy["PolicyArn"] == policyArn:
            break
    else:
        assert False, f"IAM role {roleName} does not have the expected policy attached"


def test_addon_addition():
    """
    Test whether the Amazon EBS CSI Driver add-on is added to an existing EKS cluster.

    This test checks whether the specified add-on is present in the cluster using the AWS CLI.
    The test fails if the add-on is not present or if there is an error in the AWS CLI command.

    Assumes that the add-on has been successfully added to the cluster using Terraform.

    Raises:
        AssertionError: If the add-on is not present in the cluster or if there is an error in the AWS CLI command.

    """
    clusterName = "xkops-cluster-2"
    addonName = "aws-ebs-csi-driver"
    region = "ap-southeast-1"
    try:
        addonInfo = subprocess.check_output(
            [
                f"aws eks describe-addon --addon-name {addonName} --cluster-name {clusterName} --region {region}"
            ],
            shell=True,
            text=True,
        )
        addonInfo = json.loads(addonInfo)
        assert addonInfo["addon"]["addonName"] == addonName
    except subprocess.CalledProcessError:
        assert False, f"Addon {addonName} does not exist"
