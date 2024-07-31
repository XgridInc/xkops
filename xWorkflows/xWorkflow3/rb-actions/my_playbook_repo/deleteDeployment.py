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

"""
Module for deleting a deployment
"""
import logging

from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    DeploymentEvent,
    action,
)


@action
def deleteDeployment(event: DeploymentEvent):
    """
    Deletes a persistent volume
    """
    if not event.get_deployment():
        logging.error("Failed to get the Deployment for deletion")
        return
    deployment = event.get_deployment()
    deploymentName= deployment.metadata.name
    event.get_deployment().delete()

    functionName = "deleteDeployment"
    finding = Finding(
        title="Deployment deletion",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    finding.add_enrichment(
        [
            MarkdownBlock(f"{deploymentName} is deleted."),
        ]
    )
    event.add_finding(finding)
