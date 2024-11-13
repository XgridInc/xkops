# XkOps

![XkOps - Kubernetes Observability Tool](./images/xkops_logo.png "XkOps Logo")
[![Lint Code Base](https://github.com/XgridInc/xkops/actions/workflows/linter.yml/badge.svg)](https://github.com/XgridInc/xkops/actions/workflows/linter.yml)
[![Package and Publish Docker Image](https://github.com/XgridInc/xkops/actions/workflows/build_publish_scan.yml/badge.svg)](https://github.com/XgridInc/xkops/actions/workflows/build_publish_scan.yml)
[![Shellcheck](https://github.com/XgridInc/xkops/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/XgridInc/xkops/actions/workflows/shellcheck.yml)

## 📘 Overview

**XkOps** is a unified observability and management solution designed to simplify Kubernetes cluster operations, with a focus on **observability**, **reliability**, **security**, and **cost control**. By integrating powerful open-source tools like **Kubecost**, **Robusta**, and **Pixie**, XkOps provides a seamless, all-in-one experience for managing and optimizing Kubernetes environments.

This platform offers users an end-to-end setup for monitoring, cost analysis, and security insights directly in their Kubernetes clusters, allowing for smarter resource allocation and operational efficiency. XkOps consolidates critical information from these tools to provide a central, intuitive interface for making informed, real-time decisions.

## 📋 Key Features

### Effortless Installation 
Easily deploy XkOps by visiting Artifact Hub and following the Helm chart installation instructions. It’s designed for quick setup and easy deployment, reducing the complexity of integrating multiple tools.

### Centralized Observability
Gain deep visibility into your Kubernetes cluster with integrated observability tools like Pixie, providing real-time monitoring and insights to track cluster health.

### Cost Management
Kubecost integration delivers detailed cost analysis and recommendations, helping teams optimize their Kubernetes workloads and reduce unnecessary spend.

### Actionable Insights
The XkOps frontend allows users to view actionable insights and directly interact with alerts and recommendations, streamlining decision-making and operational tasks.

### Integrated Workflows
Benefit from pre-configured workflows that combine Kubecost, Robusta, and Pixie for a seamless Kubernetes management experience that covers cost, observability, and security.

## 🏗️ XkOps Architecture Diagram

![XkOps Architecture Diagram](./images/arch%20diagram.png "Architecture Digram")

## 🛠️ Use cases

XkOps can be used for several use cases, including:

**Observability:** XkOps provides detailed visibility into the behavior and performance of applications running in the Kubernetes cluster, including metrics, logs, and traces. This allows teams to identify and diagnose performance issues and respond quickly to ensure the availability and stability of the applications.

**Cost Management:** XkOps provides cost and usage insights, including granular breakdowns of resource usage, and the ability to identify and address over-provisioning and under-utilization in a Kubernetes cluster. The platform also provides cost forecasting and optimization recommendations, allowing teams to plan for future growth and manage expenses more effectively.

**Security:** XkOps provides detailed visibility into the behavior and performance of applications deployed in a Kubernetes cluster, helping teams identify and address security issues, such as misconfigurations or vulnerabilities. The platform also provides alerts and notifications of suspicious activity, enabling teams to respond quickly to potential security threats.

**Alerting:** XkOps provides alerting capabilities to notify teams of issues in any Kubernetes cluster in near real-time, enabling them to quickly address problems before they become critical.

**Reporting:** XkOps allows users to generate reports to share with stakeholders about the cost, performance, and security of the Kubernetes cluster over time.

### 📥 Install XkOps

### Prerequisites
Before installing XkOps, ensure the following:

- **Kubernetes Cluster**: A running Kubernetes cluster (EKS, GKE, or another provider).
- **Helm:** Helm 3.x installed to deploy XkOps using Helm charts.
- **kubectl:** Installed and configured to interact with your Kubernetes cluster.

For further details on environment setup, refer to the Prerequisites Documentation.

### Installation

- Visit the [Artifact Hub](https://artifacthub.io/).
- Search for the XkOps Helm chart.
- Follow the installation instructions provided on the Artifact Hub page.

For more detailed steps and configurations, refer to the Installation Documentation.

## 🗺️ Road Map

To report a new feature request or to report any issues or bugs encountered while using XkOps, please feel free to [create a new issue](https://github.com/XgridInc/xkops/issues "create a new issue") on the project's GitHub repository or contact the development team via [Slack Channel](https://join.slack.com/t/xkopscommunity/shared_invite/zt-1u8xzjvvq-B52TJ2XE861v3KDvpA9UVg). The following features are currently either in progress or planned:

- [X] Checking for observability tools in your Kubernetes cluster.
- [X] Installing tools to mitigate risk.
- [X] Using Robusta to monitor and troubleshoot clusters.
- [X] Employing Kubecost for cost optimization.
- [ ] Utilizing Pixie to monitor system performance.
- [X] Deployment using Helm charts.
- [X] Implementation of a user interface.
- [ ] Determining risk factors based on metrics from your Kubernetes cluster.
- [ ] Extracting logs from pod using a logging solution

## 🤝 How to contribute

We invite you to contribute to XkOps, which is a community driven project.  If you plan on contributing code, kindly go through our [contribution guide](https://github.com/XgridInc/xkops/blob/master/CONTRIBUTING.md).

- To report a bug or request a feature, you can submit a [GitHub issue](https://github.com/XgridInc/xkops/issues "create a new issue").
- For real-time discussions and immediate assistance, please join our [Slack channel](https://join.slack.com/t/xkopscommunity/shared_invite/zt-1u8xzjvvq-B52TJ2XE861v3KDvpA9UVg).

## 🧾 License

XkOps is licensed under Apache License, Version 2.0. See [LICENSE.md](https://github.com/XgridInc/xkops/blob/master/LICENSE "LICENSE.md") for more information
