Observability is vital for ensuring that a Kubernetes cluster is cost-effective, secure, and reliable. To achieve optimal cost efficiency, state-of-the-art security, and dependable application performance, gaining insight into the cluster through observability is a necessity. True completeness in observability can only be achieved if the Kubernetes cluster is optimized for cost, reliably fault-tolerant, and secure.

Observability is crucial, and the three core concepts it encompasses - cost optimization, reliability, and security - are equally important. However, due to the abundance of tools available, it can become overwhelming to implement and manage multiple data platforms. This leads to additional costs and the need to secure each platform individually.

What is needed is a unified platform that provides true observability across the Kubernetes cluster while also being cost-optimized, fault-tolerant, and secure.

XkOps is a powerful and comprehensive solution that simplifies Kubernetes observability challenges. It achieves this by combining popular open-source tools like Kubecost, Robusta, and Pixie into a single Helm chart. This results in improved cost control, reliability, and security in cluster operations, which ultimately enhances observability. With XkOps, users can conveniently assess the costs, reliability, and security of their Kubernetes clusters, making it easier to manage their clusters and derive valuable insights. Additionally, XkOps integrates these tools to provide seamless and coherent functionality with minimal human intervention. This combination of powerful tools makes Kubernetes’ observability and cluster management more efficient, cost-effective, and secure.

XkOps addresses this issue by consolidating multiple tools for CRS into a single platform. It includes a Docker image that can be run as a Pod inside a Kubernetes cluster, which deploys tools for cost optimization, observability, and security. Additionally, XkOps also provides a Dashboard that gives rich visualization of the insights across all three dimensions, and a single truth source for the CRS metrics, making it easy for users to track and make decisions.

XkOps streamlines the deployment and management of essential observability tools by leveraging Helm and Helmfile. Traditionally, installing and configuring Kubecost, Robusta, and Pixie individually can be time-consuming and error-prone. XkOps simplifies this process by providing pre-configured Helm charts and Helmfile templates, enabling rapid deployment and configuration.

Beyond installation, XkOps empowers users to create powerful workflows by combining the capabilities of integrated tools. For instance, Kubecost’s cost optimization recommendations can be automatically implemented using Robusta actions. XkOps also offers pre-built workflows for common tasks like reclaiming unused persistent volumes, gathering node information, and addressing abandoned workloads. To facilitate data-driven insights, XkOps utilizes MongoDB as a centralized repository for storing recommendations, actions, and other relevant metrics. Users can further extend XkOps' functionality by defining custom workflows using values.yaml file.

XkOps Architecture 

XkOps Architecture

Pod for Querying Kubecost

A Kubernetes pod is deployed to periodically query Kubecost, which is a tool used for monitoring and optimizing Kubernetes costs.

The pod is configured to run based on a cron expression, which defines the schedule for querying Kubecost (e.g., every hour, daily, etc.).

The pod's role is to fetch relevant cost data from Kubecost based on specific workflows. Workflows could be related to monitoring the cost of certain resources or workloads in the Kubernetes cluster.

Once the data is retrieved, it is processed and stored in MongoDB, which serves as the persistent storage for cost-related data. MongoDB is ideal for this purpose due to its document-based structure, which allows flexible and efficient data storage.

The pod may also have logging mechanisms to ensure that queries and updates to MongoDB are tracked and can be monitored for future reference.

Backend API Endpoint

The backend is implemented using Flask, providing a lightweight yet powerful API service. One of the key API endpoints is designed to handle requests from the dashboard (the frontend).

When users interact with the web dashboard (which is built using React), they may trigger specific workflows or actions related to cost analysis, system monitoring, or other operational tasks.

The API endpoint in the Flask backend receives these requests and processes them accordingly. The request may contain parameters, such as which workflow to execute or what cost data to retrieve.

Once the API processes the request, it triggers a call to Robusta to perform the necessary action based on the input from the dashboard.

Interaction with Robusta

Robusta is a Kubernetes-native automation and observability platform that can automate operational tasks. In this system, Robusta is used to perform actions based on requests from the Flask backend.

When the backend API triggers a call to Robusta, it provides the necessary details (e.g., which workflow to execute, actions to perform, etc.).

Robusta responds by carrying out the specified task, such as restarting pods, scaling workloads, monitoring certain metrics, or adjusting resources based on cost optimization insights from Kubecost.

Robusta operates seamlessly within the Kubernetes cluster, making it an ideal tool for automating complex operational workflows and ensuring that tasks are executed efficiently and reliably.

Updating MongoDB

After Robusta completes the action requested by the backend, it returns the results or status of the operation.

The backend processes the response and updates the MongoDB database accordingly. MongoDB stores the results of these workflows, which could include the outcomes of cost optimizations, resource adjustments, or other automated actions taken by Robusta.

By updating MongoDB, the system ensures that there is a persistent record of all actions taken, which can later be queried for auditing, reporting, or further analysis.

User Interaction via Dashboard

The web dashboard, built using React, serves as the frontend where users can interact with the system.

From the dashboard, users can monitor cost data, trigger workflows, and view the results of actions taken by Robusta. The backend API acts as the intermediary between the dashboard and Robusta, ensuring that user requests are processed efficiently.

The dashboard also provides visibility into the MongoDB data, allowing users to track cost trends, view action logs, and analyze the impact of changes made by Robusta.

Intended Audience

XkOps mainly targets the following teams.

DevOps teams: DevOps teams are responsible for the deployment, scaling, and maintenance of containerized applications on Kubernetes. XkOps would provide these teams with the visibility and insights they need to ensure the performance and availability of the applications.

SRE teams: Site reliability engineers (SREs) are responsible for ensuring the reliability, scalability, and performance of production systems. XkOps would provide SREs with the necessary information to identify and diagnose performance issues in a Kubernetes cluster and make informed decisions about resource allocation and cost optimization.

Operations teams: Operations teams are responsible for the day-to-day management and monitoring of production systems. XkOps would provide these teams with the visibility they need to proactively identify and address issues, and ensure the overall health and stability of the applications.

Cloud engineers and Architects: They are responsible for designing and maintaining cloud-based infrastructures for their organizations, XkOps could provide them with a unified view of their k8s clusters and cloud-based resources and also offer cost forecasting and optimization recommendations that could help them make informed decisions about resource allocation and cost optimization.

Developers: Developers who write code for containerized applications could use XkOps to understand how their applications are performing, and the infrastructure they are running on.