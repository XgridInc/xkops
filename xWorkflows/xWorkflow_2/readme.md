
# X-Workflow 2: Detecting Unutilized Nodes in a Kubernetes Cluster

## Overview

X-Workflow 2 aims to identify unutilized nodes in a Kubernetes cluster, and display them on a dashboard using API for user information. The workflow involves querying Kubecost for cost-based node utilization data, storing this information in MongoDB, and providing a user interface for node monitoring.

## Getting Started

### Prerequisites

- Docker
- Kubernetes cluster
- Kubecost setup on k8s cluster

### Installation and Deployment

1. **Setup Kind Cluster**: Deploy a Kind cluster for local Kubernetes testing using `kind_cluster/kind_cluster.yaml`.

   ```bash
   kubectl apply -f kind_cluster/kind_cluster.yaml
   ```
2. **Install Kubecost**: Follow the instructions to install Kubecost on your Kubernetes cluster.
    [Kubecost Installation Guide](https://docs.kubecost.com/install-and-configure/install)

4.  **Deploy MongoDB stateful set**: Deploy MongoDB using the StatefulSet configuration (`k8s_yaml_files/mongodb-statefuleset.yaml`).
    
   ```bash
   kubectl apply -f k8s_yaml_files/mongodb-statefuleset.yaml
   ```
    
5.  **Deploy Kubecost Query Pod**: Deploy the Kubecost query pod using its Pod configuration (`k8s_yaml_files/kubecost_query_pod.yaml`).
    
   ```bash
    kubectl apply -f k8s_yaml_files/kubecost_query_pod.yaml
   ```
    
6.  **Deploy Flask Backend**: Deploy the Flask backend and dashboard using their Deployment configuration (`k8s_yaml_files/flask-backend-deployment.yaml`).
        
   ```bash
   kubectl apply -f k8s_yaml_files/flask-backend-deployment.yaml 
   ```
    
7.  **Access the API**: Access the backend API by port-forwarding the Flask backend service.

   ```bash
   kubectl port-forward svc/flask-backend-service 5000:5000 
   ```

After port-forwarding, the API can be accessed at `http://localhost:5000`.
    
## 🧾 License

XkOps is licensed under Apache License, Version 2.0. See [LICENSE.md](https://github.com/XgridInc/xkops/blob/master/LICENSE "LICENSE.md") for more information