# XkOps

![Xgrid Logo](https://media-exp1.licdn.com/dms/image/C4D0BAQHn43yTM8np2Q/company-logo_200_200/0?e=2159024400&v=beta&t=HCCA_wnetIM7butwiHWBYnXgVzn4pjM9Dq5YDMMJIkE "Xgrid Logo")


[![Lint Code Base](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml)
[![Package and Publish Docker Image](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml)
[![Shellcheck](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml)

## 💻 Overview

XkOps is a software platform designed to help users optimize the deployment and management of Kubernetes clusters. The platform provides a comprehensive evaluation of costs, observability, and security. XkOps makes it easy for users to gain insights and manage their cluster by packaging leading open-source tools such as Kubecost, Robusta, and Pixie into a single, easy-to-deploy Docker image that runs as a Pod. This all-in-one solution consolidates the insights obtained from these tools, making it easier for users to make informed decisions and have centralized monitoring of their Kubernetes cluster.

## Why XkOps?
XkOps is a unified platform that provides true observability across Kubernetes clusters while being cost-optimized, fault-tolerant, and secure. With an abundance of tools available, implementing and managing multiple data platforms can become overwhelming and lead to additional costs. XkOps simplifies this by offering a single platform that provides a single source of truth, making it easier for users to gain insights and manage their cluster. Achieving optimal cost efficiency, state-of-the-art security, and dependable application performance through observability is a necessity for Kubernetes clusters. XkOps addresses this by encompassing the three core concepts of cost optimization, reliability, and security in a single platform.

## 🛠️ Use cases

XkOps can be used for several use cases, including:

**Observability:** XkOps provides detailed visibility into the behavior and performance of applications running in the Kubernetes cluster, including metrics, logs, and traces. This allows teams to identify and diagnose performance issues and respond quickly to ensure the availability and stability of the applications.

**Cost Management:** XkOps provides cost and usage insights, including granular breakdowns of resource usage, and the ability to identify and address over-provisioning and under-utilization in a Kubernetes cluster. The platform also provides cost forecasting and optimization recommendations, allowing teams to plan for future growth and manage expenses more effectively.

**Security:** XkOps provides detailed visibility into the behavior and performance of applications deployed in a Kubernetes cluster, helping teams identify and address security issues, such as misconfigurations or vulnerabilities. The platform also provides alerts and notifications of suspicious activity, enabling teams to respond quickly to potential security threats.

**Alerting:** XkOps provides alerting capabilities to notify teams of issues in any Kubernetes cluster in near real-time, enabling them to quickly address problems before they become critical.

**Reporting:** XkOps allows users to generate reports to share with stakeholders about the cost, performance, and security of the Kubernetes cluster over time.


## ➕ Dependencies

- Internet connection required to download dependencies for installing tools.
- Pod resource requirements are: Memory is 200MiB and CPU is 500m
- Separate XkOps namespace
- Clusterrole and Clusterrole binding to provide the necessary permissions for XkOps to access the Kubernetes API and resources, in order to run checker scripts.
- Configmap containing data such as cluster name
- Storage class with provisioner set as EBS to enable dynamic volume provisioning
## Demo
Check out the XkOps demo here.

[XkOps Demo](https://drive.google.com/file/d/1dqWMABhVz6Mlm0vEhFN4dKy-wP6v9CT2/view?usp=sharing)
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
