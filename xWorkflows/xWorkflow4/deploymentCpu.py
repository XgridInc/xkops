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
    updateCpuRequest: str

@action
def deploymentCpu(event: DeploymentEvent, params: resizeParams):
    """
    Change the CPU requests of a Deployment
    """
    if not event.get_deployment():
        # Log an error message if the deployment is not found
        logging.error("Failed to get the deployment for CPU adjustment")
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

        # Update the CPU requests in the Deployment spec
        for container in deploymentSpec.spec.template.spec.containers:
            container.resources.requests['cpu'] = params.updateCpuRequest

        # Update the Deployment with the modified spec
        apps_v1.patch_namespaced_deployment(
            name=deploymentName,
            namespace=deploymentNamespace,
            body={"spec": deploymentSpec.spec}
        )

        logging.info(f"Deployment {deploymentName} in namespace {deploymentNamespace} has been updated with new CPU requests.")
    except client.exceptions.ApiException as e:
        logging.error(f"Exception when modifying deployment: {e}")

    functionName = "Change CPU requests of Deployment"
    finding = Finding(
        title="Deployment CPU upgradation",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    print(params)
    finding.add_enrichment(
        [
            MarkdownBlock(f"{deploymentName} CPU is Upgraded."),
        ]
    )
    event.add_finding(finding)
