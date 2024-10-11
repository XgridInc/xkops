import logging
from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    StatefulSetEvent,
    action,
    ActionParams,
)
from kubernetes import client, config

class resizeParams(ActionParams):
    updateCpuRequest: str

@action
def statefulSetCpu(event: StatefulSetEvent, params: resizeParams):
    """
    Change the CPU requests of a StatefulSet
    """
    if not event.get_statefulset():
        # Log an error message if the StatefulSet is not found
        logging.error("Failed to get the StatefulSet for CPU adjustment")
        return
    
    statefulSet = event.get_statefulset()
    statefulSetName = statefulSet.metadata.name
    statefulSetNamespace = statefulSet.metadata.namespace

    # Load the kube config
    config.load_incluster_config()

    # Create a Kubernetes API client
    apps_v1 = client.AppsV1Api()

    try:
        # Read the existing StatefulSet specification
        statefulSetSpec = apps_v1.read_namespaced_stateful_set(name=statefulSetName, namespace=statefulSetNamespace)

        # Update the CPU requests in the StatefulSet spec
        for container in statefulSetSpec.spec.template.spec.containers:
            if container.resources.requests is None:
                container.resources.requests = {}
            container.resources.requests['cpu'] = params.updateCpuRequest

        # Update the StatefulSet with the modified spec
        apps_v1.patch_namespaced_stateful_set(
            name=statefulSetName,
            namespace=statefulSetNamespace,
            body={"spec": statefulSetSpec.spec}
        )

        logging.info(f"StatefulSet {statefulSetName} in namespace {statefulSetNamespace} has been updated with new CPU requests.")

        functionName = "Change CPU requests of StatefulSet"
        finding = Finding(
            title="StatefulSet CPU upgradation",
            source=FindingSource.MANUAL,
            aggregation_key=functionName,
            finding_type=FindingType.REPORT,
            failure=False,
        )
        print(params)
        finding.add_enrichment(
            [
                MarkdownBlock(f"{statefulSetName} CPU is Upgraded."),
            ]
        )
    except client.exceptions.ApiException as e:
        logging.error(f"Exception when modifying StatefulSet: {e}")
        functionName = "Change CPU requests of StatefulSet Failed"
        finding = Finding(
            title="StatefulSet CPU upgradation Failed",
            source=FindingSource.MANUAL,
            aggregation_key=functionName,
            finding_type=FindingType.REPORT,
            failure=False,
        )
        print(params)
        finding.add_enrichment(
            [
                MarkdownBlock(f"{statefulSetName} CPU Upgradation Failed."),
            ]
        )

    event.add_finding(finding)
