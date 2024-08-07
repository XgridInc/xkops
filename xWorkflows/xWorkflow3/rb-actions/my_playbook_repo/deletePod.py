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
Module for deleting a pod
"""
import logging

from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    PodEvent,
    action,
)


@action
def deletePod(event: PodEvent):
    """
    Deletes a persistent volume
    """
    # Check if the persistent volume is present
    if not event.get_pod():
        # Log an error message if the volume is not found
        logging.error("Failed to get the pod for deletion")
        return
    pod = event.get_pod()
    podName= pod.metadata.name
    event.get_pod().delete()

    # Create a Finding object to store and send the details of the deleted volume
    functionName = "deletePod"
    finding = Finding(
        title="Pod deleted",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    # Add a MarkdownBlock to the finding object to display the deleted volume name
    finding.add_enrichment(
        [
            MarkdownBlock(f"{podName} is deleted."),
        ]
    )
    event.add_finding(finding)
