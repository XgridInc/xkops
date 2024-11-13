Prerequisites

What are the basic requirements for installing XkOps? 
To install XkOps, you'll need a Kubernetes cluster with the cluster-admin role or equivalent permissions, and Helm 3.x or later installed on your system.

Do I need a specific Kubernetes version for XkOps? 
XkOps is compatible with Kubernetes versions 1.18 and above. For optimal performance and feature support, it's recommended to use the latest stable Kubernetes version.

Can I use a managed Kubernetes service for XkOps? 
Yes, XkOps can be installed on the most popular managed Kubernetes services like Amazon EKS, Google Kubernetes Engine (GKE), and Azure Kubernetes Service (AKS).

Installation

How do I add the XkOps Helm repository? 
To add the XkOps Helm repository, run the following command in your terminal:

helm repo add xkops https://xgridinc.github.io/xkops/charts/stable


How do I install XkOps using Helm? 
Install XkOps using the following Helm command:

helm install my-xkops xkops/xkops -f values.yaml


 Replace my-xkops with your desired release name and specify your custom values file if needed.

Can I customize the XkOps installation? 
Yes, you can customize the XkOps installation by modifying the values.yaml file. This allows you to adjust resource requests, image tags, and other configuration options.

Verification

How can I verify if XkOps is installed successfully? 
Check the status of XkOps deployments and pods using kubectl get deployments and kubectl get pods. All components should have a status of "Running".

Troubleshooting

What if some XkOps components are not running? 
Inspect the logs of the failing components using kubectl logs <pod-name>. Check for error messages indicating configuration or resource issues.

How do I troubleshoot connectivity issues between XkOps components? 
Inspect Kubernetes service definitions and network policies. Verify pod network connectivity using tools like kubectl exec and curl.

Can I uninstall XkOps and reinstall it? 
Yes, you can uninstall XkOps using helm uninstall and then reinstall it using the same command.

General

Do I need any specific network configurations for XkOps? 
Ensure your Kubernetes cluster has network connectivity to required external services (e.g., container registries) and that necessary ports are open.

Where can I find additional support resources for XkOps? 
Refer to the official XkOps documentation, and community forums, or contact XkOps support for assistance.