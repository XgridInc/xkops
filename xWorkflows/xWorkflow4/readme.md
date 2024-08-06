
# X-Workflow 4: Container Requests Right Sizing in a Kubernetes Cluster

## Overview

X-Workflow 4 aims to identify the right size of container requests in a Kubernetes cluster, and display them on a dashboard using API for user information. The workflow involves querying Kubecost for cost-based workloads utilization data, storing this information in MongoDB, and providing a user interface for cluster monitoring.



## How it Works:

1. **Kubecost Query Pod**:
   - The query pod continuously queries Kubecost to retrieve pods data based on container requests.
   - The query pod dumps this data into a MongoDB database deployed as a StatefulSet in the cluster.
2. **Flask Backend**:
   - The backend pod queries the MongoDB database to display results to users about resize the container requests.
3. **Robusta Action**
   - The robusta actions will reize the container requests.

## Robusta Action:
We have to create the robusta action for pods, deployments, deamonsets and statefulset etc.
In case of pods, flask API will call robusta action by passing the name, namespace and updated values(CPU or memeory).
```bash
# Pod Schema
name: <podname>
namespace: <podnamespace>
updateCpuRequest: <Updated CPU request> 
"OR"  
updateMemoryRequest: <Updated Memeory Request>
```
Note incase of Deployment "name" field requires the name of deployment instead of podname rest remains same. This rule should be same for Daemonset and Statefulset meaning instead of pod name we need the name of the resource.

### Schema for Pods
The name of the actions in case of pods are:
```bash
podCpu and podMemory
```
```bash
# Pod Schema
name: <podname>
namespace: <podnamespace>
updateCpuRequest: <Updated CPU request> 
"OR"  
updateMemoryRequest: <Updated Memeory Request>
```
So the final schema would be like this:
```bash
# Incase of cpu
        payload = {
            "action_name": "podCpu",
            "action_params": {"name": podname, "namespace": podnamespace,"updateCpuRequest":cpuRequests}
        },
# Incase of memory
        payload = {
            "action_name": "podMemory",
            "action_params": {"name": podname, "namespace": podnamespace,"updateMemoryRequest":cpuRequests}
        }
```
### Schema for Deployment 
The name of the actions in case of deployments are:
```bash
deploymentCpu and deploymentMemory
```
```bash
name: <deploymentname>
namespace: <deploymentnamespace>
updateCpuRequest: <Updated CPU request> 
"OR"  
updateMemoryRequest: <Updated Memeory Request>
```
So the final schema would be like this:
```bash
# Incase of cpu
        payload = {
            "action_name": "deploymentCpu",
            "action_params": {"name": deploymentname, "namespace": deploymentnamespace,"updateCpuRequest":cpuRequests}
        },
# Incase of memory
        payload = {
            "action_name": "deploymentMemory",
            "action_params": {"name": deploymentname, "namespace": deploymentnamespace, "updateMemoryRequest":cpuRequests}
        }
```