import logging
import time
from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    PodEvent,
    action,
    ActionParams,
)
from kubernetes import client, config

class resizeParams(ActionParams):
    updateMemoryRequest: str

@action
def podMemory(event: PodEvent, params: resizeParams):
    """
    Change the Memory requests of a Pod
    """
    if not event.get_pod():
        # Log an error message if the pod is not found
        logging.error("Failed to get the pod for Memory adjustment")
        return
    
    pod = event.get_pod()
    podName = pod.metadata.name
    podNamespace = pod.metadata.namespace

    # Load the kube config
    config.load_incluster_config()

    # Create a Kubernetes API client
    core_v1 = client.CoreV1Api()

    try:
        # Read the existing Pod specification
        podSpec = core_v1.read_namespaced_pod(name=podName, namespace=podNamespace)

        # Create a new Pod spec without resource_version
        new_pod_spec = client.V1Pod(
            metadata=client.V1ObjectMeta(
                name=pod.metadata.name,
                namespace=pod.metadata.namespace,
                labels=pod.metadata.labels,
                annotations=pod.metadata.annotations,
            ),
            spec=podSpec.spec,
        )

        # Update the CPU requests in the new Pod spec
        for container in new_pod_spec.spec.containers:
            container.resources.requests['memory'] = params.updateMemoryRequest

        # Delete the existing Pod
        core_v1.delete_namespaced_pod(name=podName, namespace=podNamespace)

        # Wait for the Pod to be fully deleted
        for _ in range(30):  # Retry up to 30 times
            try:
                # Check if the pod is deleted
                core_v1.read_namespaced_pod(name=podName, namespace=podNamespace)
                time.sleep(1)  # Wait for a short time before retrying
            except client.exceptions.ApiException as e:
                if e.status == 404:  # Pod not found, which means it’s deleted
                    break
                raise  # Reraise other exceptions

        # Recreate the Pod with the updated specification
        core_v1.create_namespaced_pod(namespace=podNamespace, body=new_pod_spec)

        logging.info(f"Pod {podName} in namespace {podNamespace} has been updated with new Memory requests.")
    except client.exceptions.ApiException as e:
        logging.error(f"Exception when modifying pod: {e}")


    functionName = "Change Memory requests of Pod"
    finding = Finding(
        title="Pod Memory upgradation",
        source=FindingSource.MANUAL,
        aggregation_key=functionName,
        finding_type=FindingType.REPORT,
        failure=False,
    )
    print(params)
    finding.add_enrichment(
        [
            MarkdownBlock(f"{podName} Memory is Upgraded."),
        ]
    )
    event.add_finding(finding)
