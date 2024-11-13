This section provides detailed instructions for creating a new workflow in XkOps. Workflows are a core component of XkOps, allowing you to automate and manage specific actions within your Kubernetes environment. To ensure optimal performance and maintain system standards, it is recommended to create only those workflows that meet the requirements. For more details on these requirements, please refer to the **“Workflow Creation Criteria”** document.

To create a new workflow, follow these steps:

## Create a Necessary Robusta Action

Begin by defining the required Robusta action that aligns with your specific needs. Robusta actions are modular components within xkops, designed to execute targeted tasks in response to workflow triggers. Carefully assess your requirements and create a robust action that effectively addresses your objectives, whether it involves resource management, system monitoring, or automated scaling.

## Integrate Business Logic in the Query Pod Section

After defining the Robusta action, move on to configuring the Query Pod section where the business logic resides. Here, a cron job will be set up to retrieve cost recommendations from Kubecost pods. Kubecost provides cost optimization insights, which can be valuable for controlling resource expenses within your Kubernetes environment.

Within the Query Pod, refine the logic to retrieve cost recommendations specifically from the Kubecost APIs that align with your requirements. This targeted approach ensures that the workflow only pulls in relevant cost data, reducing unnecessary overhead and focusing on actionable recommendations. Be sure to customize the cron job timing to align with your monitoring and optimization intervals.

## Develop Supporting Backend APIs in Flask

The final step involves building the backend APIs to support your Robusta action, using Flask. These APIs provide the interface needed to trigger, monitor, and manage the Robusta action, integrating seamlessly with the cost recommendations logic. It is also recommended to implement authentication, logging, and error handling for these APIs to enhance their reliability and maintain a secure audit trail of all workflow activities.