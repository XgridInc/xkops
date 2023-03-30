# XkOps

![Xgrid Logo](https://media-exp1.licdn.com/dms/image/C4D0BAQHn43yTM8np2Q/company-logo_200_200/0?e=2159024400&v=beta&t=HCCA_wnetIM7butwiHWBYnXgVzn4pjM9Dq5YDMMJIkE "Xgrid Logo")


[![Lint Code Base](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/linter.yml)
[![Package and Publish Docker Image](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/build_publish_scan.yml)
[![Shellcheck](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/X-CBG/xk8s/actions/workflows/shellcheck.yml)

## 💻 Overview

XkOps is a software platform designed to help users optimize the deployment and management of Kubernetes clusters. The platform provides a comprehensive evaluation of costs, observability, and security.
XkOps makes it easy for users to gain insights and manage their cluster by packaging leading open-source tools such as Kubecost, Robusta, and Pixie into a single, easy-to-deploy Docker image that runs as a Pod.
This all-in-one solution consolidates the insights obtained from these tools, making it easier for users to make informed decisions and have centralized monitoring of their Kubernetes cluster.

Check the below video for a quick demo of XkOps.
[![XkOps Demo](./screenshots/Demo-video.png)](https://drive.google.com/file/d/1dqWMABhVz6Mlm0vEhFN4dKy-wP6v9CT2/view?usp=sharing)


## 💡 Why XkOps?
XkOps is a unified platform that provides true observability across Kubernetes clusters while being cost-optimized, fault-tolerant, and secure. With an abundance of tools available, implementing and managing multiple data platforms can become overwhelming and lead to additional costs.

XkOps simplifies this by offering a single platform that provides a single source of truth, making it easier for users to gain insights and manage their cluster. Achieving optimal cost efficiency, state-of-the-art security, and dependable application performance through observability is a necessity for Kubernetes clusters.
XkOps addresses this by encompassing the three core concepts of cost optimization, reliability, and security in a single platform.

## 🛠️ Use cases

XkOps can be used for several use cases, including:

**Observability:** XkOps provides detailed visibility into the behavior and performance of applications running in the Kubernetes cluster, including metrics, logs, and traces. This allows teams to identify and diagnose performance issues and respond quickly to ensure the availability and stability of the applications.

**Cost Management:** XkOps provides cost and usage insights, including granular breakdowns of resource usage, and the ability to identify and address over-provisioning and under-utilization in a Kubernetes cluster. The platform also provides cost forecasting and optimization recommendations, allowing teams to plan for future growth and manage expenses more effectively.

**Security:** XkOps provides detailed visibility into the behavior and performance of applications deployed in a Kubernetes cluster, helping teams identify and address security issues, such as misconfigurations or vulnerabilities. The platform also provides alerts and notifications of suspicious activity, enabling teams to respond quickly to potential security threats.

**Alerting:** XkOps provides alerting capabilities to notify teams of issues in any Kubernetes cluster in near real-time, enabling them to quickly address problems before they become critical.

**Reporting:** XkOps allows users to generate reports to share with stakeholders about the cost, performance, and security of the Kubernetes cluster over time.

## ➕ Dependencies
Please note the following requirements for using the XkOps:

- To install the necessary dependencies, an internet connection is required.
- You will need an EKS cluster and an AWS IAM user with a minimum set of permissions listed in this [spreadsheet](https://docs.google.com/spreadsheets/d/1cuC-72oRJ7DB4HkvELpml5RLcA2clzCA7xBVd1z6fVw/edit?usp=sharing).
- The pod resources must meet the minimum requirements of 200MiB memory and 500m CPU.
- Please ensure that you use a separate XkOps namespace.
## 📒 Getting Started
To install XkOps, please follow these steps
### 🔐 Secret Manager Setup
First, set up AWS secrets manager on your AWS account:
- Refer to this [guide](https://docs.google.com/document/d/17fhQ0zJZtJGcWtnVD8NehUbFC-x9TrMP11XjyEFi370/edit?usp=sharing) for instructions on how to set up AWS secret manager OR
- Use [this script](Place holder for file link-PR to be reviewed for this) to automate the setup process.

### 📥 Install XkOps
1. Clone the repository and navigate to the cloned repo:
    ```commandline
    git clone https://github.com/X-CBG/xk8s.git && cd xk8s
    ```
2. Update values.yaml file and input your specific value for each key.
3. Install XkOps using Helm:
    ```commandline
    helm install xkops ./helm -f values.yml
    ```
4. After successful installation, obtain the link of the XkOps frontend service to access the dashboard:
    ```commandline
    kubectl get svc -n xkops
    ```
5. Create an unclaimed volume in your cluster and delete it using the delete button on the dashboard. You can verify the volume deletion action both from the dashboard and the cluster.

## 🚧 Road Map
To report a new feature request or to report any issues or bugs encountered while using XkOps, please feel free to [create a new issue](https://github.com/X-CBG/xk8s/issues "create a new issue") on the project's GitHub repository or contact the development team at nbajwa@xgrid.co or sidra.irshad@xgrid.co via email. The following features are currently either in progress or planned:

- [X] Checking for observability tools in your Kubernetes cluster.
- [X] Installing tools to mitigate risk.
- [X] Using Robusta to monitor and troubleshoot clusters.
- [X] Employing Kubecost for cost optimization.
- [X] Utilizing Pixie to monitor system performance.
- [x] Deployment using Helm charts.
- [ ] Implementation of a user interface.
- [ ] Determining risk factors based on metrics from your Kubernetes cluster.
- [ ] Extracting logs from pod using a logging solution
## How to contribute
If you would like to help contribute to this GitHub Action, please see CONTRIBUTING.md

## 🧾 License

XkOps is distributed under the MIT License. See [LICENSE.md](https://github.com/X-CBG/xk8s/blob/master/LICENSE "LICENSE.md") for more information
