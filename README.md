# XkOps

![Xgrid Logo](https://media-exp1.licdn.com/dms/image/C4D0BAQHn43yTM8np2Q/company-logo_200_200/0?e=2159024400&v=beta&t=HCCA_wnetIM7butwiHWBYnXgVzn4pjM9Dq5YDMMJIkE "Xgrid Logo")

## A platform to determine risk factor of your Kubernetes clusters

[![Lint Code Base](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml)
[![Package and Publish Docker Image](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml)
[![Shellcheck](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml)

## 💻 About the project

XkOps is a platform for Kubernetes Risk Detection and Mitigation.
It aims to help users identify potential security risks and observability
gaps in their Kubernetes clusters by detecting the presence of certain tools and configurations.
By providing information about the risk level and observability associated with these tools,
as well as associated costs, this platform hopes to empower users to make
informed decisions about how to mitigate those risks,
improve their observability and optimize their clusters for cost efficiency.
Additionally, the project includes features to help users install recommended tools
and configurations in order to decrease the risk level of their cluster, enhance
their visibility and also optimizating their cost usage.
Whether you're new to Kubernetes or an experienced user, we hope this project will be a
useful resource for managing the security, observability and cost efficiency of your clusters.

## 🛠️ Use cases

- Identifying observability gaps: By detecting the presence of certain observability tools and configurations, the project can help users understand where their cluster may have gaps in visibility and take steps to address those gaps.
- Identifying potential security risks in a Kubernetes cluster: The project can detect the presence of certain tools and configurations that may present security risks, and provide information about the associated risk level. This can help users understand the potential vulnerabilities in their clusters and take steps to mitigate those risks.
- Improving cluster security: By installing recommended tools and configurations, users can reduce the risk level of their clusters and improve the overall security of their environments.
- Managing cloud costs: If the project is integrated with cloud providers, it can be used to monitor and manage the cost of running the clusters in cloud and take decisions such as scaling down or turning off clusters when not in use, to reduce cost.

## ➕ Dependencies

- Internet connection required to download dependencies for installing tools.
- Pod resource requirements are: Memory is 200MiB and CPU is 500m
- Separate XkOps namespace
- Clusterrole and Clusterrole binding to provide the necessary permissions for XkOps to access the Kubernetes API and resources, in order to run checker scripts.
- Configmap containing data such as cluster name
- Storage class with provisioner set as EBS to enable dynamic volume provisioning

## 📒 Getting Started

1. Clone the repository and change directory to the cloned repo:

    ```commandline
    git clone https://github.com/X-CBG/xk8s.git && cd xk8s
    ```

2. From manifests folder create `ClusterRole` and `ClusterRoleBinding` in your cluster:

    ```commandline
    kubectl apply -f AllResourcesRole.yaml
    ```

3. Build the XkOps docker image:

    ```commandline
    docker build -t myimage .
    ```

    You can also use one of the pre-built images from the [DockerHub repository](https://hub.docker.com/r/xgridxcbg/kaizen/tags "DockerHub repository")

4. In the project go to the manifests folder and use the docker image in [`xk8s-pod.yaml`](https://github.com/X-CBG/xk8s/blob/master/manifests/xk8s-pod.yaml "xk8s-pod.yaml") manifest.

    ```commandline
    kubectl create -f xk8s-pod.yaml 
    ```

5. Create a pod in your Kubernetes cluster using this [`xk8s-pod.yaml`](https://github.com/X-CBG/xk8s/blob/master/manifests/xk8s-pod.yaml "`xk8s-pod.yaml`") and observe logs:

    ```commandline
    kubectl logs -f xk8s 
    ```

    or you can view logs at `log-volume` (mounted hostPath) volume.

## 🚧 Road Map

If you want to see a new feature or if you experience any issues/bugs while using XkOps feel free to [create a new issue](https://github.com/X-CBG/xk8s/issues "create a new issue") or send an email at nbajwa@xgrid.co or sidra.irshad@xgrid.co . Here are some features which are either under way or planned:

- [X] Checking for observability tools in your Kubernetes cluster.
- [X] Installing tools to mitigate risk.
- [X] Robusta is used to monitor and troubleshoot cluster.
- [X] Kubecost is used for cost optimization.
- [X] Pixie is used to monitor system performance.
- [ ] Determining risk factor based on metrics from your Kubernetes cluster.
- [ ] Extracting logs from pod using a logging solution
- [ ] User Interface
- [ ] Using Helm charts for the deployment.

## 🧾 License

XkOps is distributed under the MIT License. See [LICENSE.md](https://github.com/X-CBG/xk8s/blob/master/LICENSE "LICENSE.md") for more information
