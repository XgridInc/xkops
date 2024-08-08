import logging
from robusta.api import (
    Finding,
    FindingSource,
    FindingType,
    MarkdownBlock,
    DaemonSetEvent,
    action,
    ActionParams,
)
from kubernetes import client, config

class resizeParams(ActionParams):
    updateCpuRequest: str

@action
def daemonSetCpu(event: DaemonSetEvent, params: resizeParams):
    """
    Change the CPU requests of a DaemonSet
    """
    if not event.get_daemonset():
        # Log an error message if the DaemonSet is not found
        logging.error("Failed to get the DaemonSet for CPU adjustment")
        return
    
    daemonSet = event.get_daemonset()
    daemonSetName = daemonSet.metadata.name
    daemonSetNamespace = daemonSet.metadata.namespace

    # Load the kube config
    config.load_incluster_config()

    # Create a Kubernetes API client
    apps_v1 = client.AppsV1Api()

    try:
        # Read the existing DaemonSet specification
        daemonSetSpec = apps_v1.read_namespaced_daemon_set(name=daemonSetName, namespace=daemonSetNamespace)

        # Update the CPU requests in the DaemonSet spec
        for container in daemonSetSpec.spec.template.spec.containers:
            container.resources.requests['cpu'] = params.updateCpuRequest

        # Update the DaemonSet with the modified spec
        apps_v1.patch_namespaced_daemon_set(
            name=daemonSetName,
            namespace=daemonSetNamespace,
            body={"spec": daemonSetSpec.spec}
        )

        logging.info(f"DaemonSet {daemonSetName} in namespace {daemonSetNamespace} has been updated with new CPU requests.")

        functionName = "Change CPU requests of DaemonSet"
        finding = Finding(
            title="DaemonSet CPU upgradation",
            source=FindingSource.MANUAL,
            aggregation_key=functionName,
            finding_type=FindingType.REPORT,
            failure=False,
        )
        print(params)
        finding.add_enrichment(
            [
                MarkdownBlock(f"{daemonSetName} CPU is Upgraded."),
            ]
        )
    except client.exceptions.ApiException as e:
        logging.error(f"Exception when modifying DaemonSet: {e}")
        functionName = "Change CPU requests of DaemonSet Failed"
        finding = Finding(
            title="DaemonSet CPU upgradation Failed",
            source=FindingSource.MANUAL,
            aggregation_key=functionName,
            finding_type=FindingType.REPORT,
            failure=False,
        )
        print(params)
        finding.add_enrichment(
            [
                MarkdownBlock(f"{daemonSetName} CPU Upgradation Failed."),
            ]
        )

    event.add_finding(finding)