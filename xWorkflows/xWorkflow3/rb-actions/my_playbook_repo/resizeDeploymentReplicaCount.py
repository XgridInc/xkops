import logging
from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    DeploymentEvent,
    ActionParams,
    action,
)
from kubernetes import client, config

class resizeParams(ActionParams):
    replicas: int

@action
def resizeDeploymentReplicaCount(event: DeploymentEvent, params: resizeParams):
    """
    Resizes the replica count of a deployment to the specified number of replicas
    """
    if not event.get_deployment():
        logging.error("Failed to get the Deployment for Resizing")
        return 
    
    deployment = event.get_deployment()
    deploymentName = deployment.metadata.name
    namespace = deployment.metadata.namespace

    # Load the kube config
    config.load_incluster_config()

    # Create a Kubernetes API client
    appsV1 = client.AppsV1Api()

    # Get the current deployment
    currentDeployment = appsV1.read_namespaced_deployment(deploymentName, namespace)

    # Modify the replica count using the parameter
    currentDeployment.spec.replicas = params.replicas

    # Update the deployment
    updatedDeployment = appsV1.replace_namespaced_deployment(
        name=deploymentName,
        namespace=namespace,
        body=currentDeployment,
    )

    logging.info(f"Resized deployment {deploymentName} to {params.replicas} replicas")
    
    functionName = "resizeDeploymentReplicaCount"
    finding = Finding(
        title="Deployment Resized",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    finding.add_enrichment(
        [
            MarkdownBlock(f"{deploymentName} has been resized to {params.replicas} replicas."),
        ]
    )
    event.add_finding(finding)
