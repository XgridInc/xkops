import logging
import time
from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    DeploymentEvent,
    action,
    ActionParams,
)
from kubernetes import client, config

class resizeParams(ActionParams):
    updateMemoryRequest: str

@action
def deploymentMemory(event: DeploymentEvent, params: resizeParams):
    """
    Change the Memory requests of a Deployment
    """
    if not event.get_deployment():
        # Log an error message if the deployment is not found
        logging.error("Failed to get the deployment for Memory adjustment")
        return
    
    deployment = event.get_deployment()
    deploymentName = deployment.metadata.name
    deploymentNamespace = deployment.metadata.namespace

    # Load the kube config
    config.load_incluster_config()

    # Create a Kubernetes API client
    apps_v1 = client.AppsV1Api()

    try:
        # Read the existing Deployment specification
        deploymentSpec = apps_v1.read_namespaced_deployment(name=deploymentName, namespace=deploymentNamespace)

        # Update the Memory requests in the Deployment spec
        for container in deploymentSpec.spec.template.spec.containers:
            container.resources.requests['memory'] = params.updateMemoryRequest

        # Update the Deployment with the modified spec
        apps_v1.patch_namespaced_deployment(
            name=deploymentName,
            namespace=deploymentNamespace,
            body={"spec": deploymentSpec.spec}
        )

        logging.info(f"Deployment {deploymentName} in namespace {deploymentNamespace} has been updated with new Memory requests.")
    except client.exceptions.ApiException as e:
        logging.error(f"Exception when modifying deployment: {e}")

    functionName = "Change Memory requests of Deployment"
    finding = Finding(
        title="Deployment Memory upgradation",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    print(params)
    finding.add_enrichment(
        [
            MarkdownBlock(f"{deploymentName} Memory is Upgraded."),
        ]
    )
    event.add_finding(finding)
