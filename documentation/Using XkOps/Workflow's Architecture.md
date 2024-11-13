## General Workflow’s Architecture

<p align="center">
  <img src="../../images/general%20workflow%20architecture.png" alt="General Workflow Architecture Diagram" title="General Workflow Architecture">
</p>

- XkOps integrates with Kubecost to obtain real-time cost details, which inform cost optimization actions within your Kubernetes cluster. By polling Kubecost endpoints, XkOps retrieves the latest costing information, ensuring that workflows are based on up-to-date data.

- Once the latest cost information is gathered, XkOps triggers a Robusta action to manage resources in alignment with cost management goals. This process ensures that any necessary adjustments are automated and informed by accurate, current financial insights.

- Depending on the user’s configuration, xkops may update or delete specific resources to optimize costs. These actions are performed as per user-defined criteria, offering flexible options to streamline and manage cluster expenses effectively.

