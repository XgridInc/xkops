
# X-Workflow 3: Detecting and deleting Abandoned Workloads in a Kubernetes Cluster

## Overview

X-Workflow 3 aims to identify unutilized workloads in a Kubernetes cluster, and display them on a dashboard using API for user information. The workflow involves querying Kubecost for cost-based workloads(ingress/egress) utilization data, storing this information in MongoDB, and providing a user interface for node monitoring.



## How it Works:

1. **Kubecost Query Pod**:
   - The query pod continuously queries Kubecost to retrieve pods data based on ingress and egress.
   - The query pod dumps this data into a MongoDB database deployed as a StatefulSet in the cluster.
2. **Flask Backend**:
   - The backend pod queries the MongoDB database to display results to users about abandonend workloads pods.

## Steps for Installation and Testing



### 1. Install Kubecost

Follow the instructions to install Kubecost on your Kubernetes cluster:
- [Kubecost Installation Guide](https://docs.kubecost.com/install-and-configure/install)

### 2. Deploy MongoDB StatefulSet

Deploy MongoDB using the StatefulSet configuration (`manifests/mongodb-statefuleset.yaml`).

```bash
kubectl apply -f k8manifests/mongodb-statefuleset.yaml
```

### 3. Deploy Kubecost Query Pod

1. **Build Docker Image for Kubecost Query Pod**:

   Navigate to the `kubecost_query_pod` directory and build the Docker image.

   ```bash
   cd kubecost_query_pod_go
   docker build -t <image_registry_name>/kubecost-query-pod -f Dockerfile .
   docker push <image_registry_name>/kubecost-query-pod
   ```

2. **Update Image Tag**:

   Update the image tag in `manifests/kubecost-query-pod.yaml` to the one you just pushed.

3. **Deploy the Kubecost Query Pod**:

   ```bash
   kubectl apply -f manifests/kubecost-query-pod.yaml
   ```

### 4. Deploy Flask Backend

1. **Build Docker Image for Flask Backend**:

   Navigate to the `backend` directory and build the Docker image.

   ```bash
   cd backend
   docker build -t <image_registry_name>/backend -f Dockerfile .
   docker push <image_registry_name>/backend
   ```

2. **Update Image Tag**:

   Update the image tag in `manifests/flask-backend.yaml` to the one you just pushed.

3. **Deploy the Flask Backend**:

   ```bash
   kubectl apply -f manifests/flask-backend.yaml
   ```

### 5. Create necessary Roles and Rolebindings

We need to create the roles and rolebindings in order to give permisstion to robusta runner to update the workloads, so that a user decrease the replicas of abandonend workloads.
   ```bash
   kubectl apply -f manifests/roles-rolebindings.yaml
   ```
The Flask backend service is set up as a ClusterIP service. You need to forward the port to access this on localhost.

### 6. Push custom actions to robusta playbooks

We need to add our custom actions to robusta playbooks.
   ```bash
    robusta playbooks push rb-actions
   ```

### 7. Access the API

The Flask backend service is set up as a ClusterIP service. You need to forward the port to access this on localhost.

1. **Find the Pod**:

   ```bash
   kubectl get pods -n <namespace>
   ```

2. **Port-forwarding**:

   ```bash
   kubectl port-forward <flask-backend-pod-name>  -n <namespace> 5000
   ```

3. **Access the API**:

   Open your browser and navigate to `http://localhost:5000` to see the API results.

### Additional Notes

- The Docker image registry needs to be publicly accessible so that the pod can pull the container image. If the registry is private, you need to set up registry authentication accordingly.

By following these steps, you should be able to set up and test the Kubecost query pod, MongoDB StatefulSet, and Flask backend successfully.

    
## 🧾 License

XkOps is licensed under Apache License, Version 2.0. See [LICENSE.md](https://github.com/XgridInc/xkops/blob/master/LICENSE "LICENSE.md") for more information