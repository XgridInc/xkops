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

import boto3
import subprocess
import json

def test_iam_role_creation():
    """
    Test if the IAM role is created by Terraform.

    The test uses Boto3 to check if the IAM role with the given name exists. If the IAM role exists,
    the test passes. If the IAM role does not exist, the test fails.

    Raises:
        AssertionError: If the IAM role with the given name does not exist.
    """
    iam_client = boto3.client('iam')
    role_name = 'XkOps-EBS-iam-role'
    try:
        role_response = iam_client.get_role(RoleName=role_name)
        assert role_response['Role']['RoleName'] == role_name
    except iam_client.exceptions.NoSuchEntityException:
        assert False, f"IAM role {role_name} does not exist"


def test_iam_policy_attachment():
    """
    Test if the IAM policy is attached to the IAM role created by Terraform.

    The test uses Boto3 to check if the IAM role with the given name has the expected policy attached.
    If the IAM role has the expected policy attached, the test passes. If the IAM role does not have
    the expected policy attached, the test fails.

    Raises:
        AssertionError: If the IAM role does not have the expected policy attached.
    """
    iam_client = boto3.client('iam')
    role_name = 'XkOps-EBS-iam-role'
    policy_arn = 'arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy'
    attached_policies_response = iam_client.list_attached_role_policies(RoleName=role_name)
    for policy in attached_policies_response['AttachedPolicies']:
        if policy['PolicyArn'] == policy_arn:
            break
    else:
        assert False, f"IAM role {role_name} does not have the expected policy attached"


def test_addon_addition():
    """
    Test whether the Amazon EBS CSI Driver add-on is added to an existing EKS cluster.

    This test checks whether the specified add-on is present in the cluster using the AWS CLI.
    The test fails if the add-on is not present or if there is an error in the AWS CLI command.

    Assumes that the add-on has been successfully added to the cluster using Terraform.

    Raises:
        AssertionError: If the add-on is not present in the cluster or if there is an error in the AWS CLI command.

    """
    cluster_name = 'xkops-cluster-2'
    addon_name = 'aws-ebs-csi-driver'
    region = 'ap-southeast-1'
    try:
        addon_info = subprocess.check_output([f'aws eks describe-addon --addon-name {addon_name} --cluster-name {cluster_name} --region {region}'], shell=True, text=True)
        addon_info = json.loads(addon_info)
        assert addon_info['addon']['addonName'] == addon_name
    except subprocess.CalledProcessError as e:
        assert False, f"Addon {addon_name} does not exist"
        