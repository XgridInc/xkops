This document outlines the installation steps for XkOps, XkOps is a powerful and comprehensive solution that simplifies Kubernetes observability challenges. It combines popular open-source tools like Kubecost, Robusta, and Pixie into a single Helm chart. This results in improved cost control, reliability, and security in cluster operations, ultimately enhancing observability.

**Target Audience:** This guide is intended for users familiar with Kubernetes and Helm package management.

## Prerequisites

**A Kubernetes Cluster:** Ensure you have a functioning Kubernetes cluster with the necessary permissions to deploy pods and resources.

**Helm:** Helm should be installed and operational on your system. Refer to the official Helm documentation for installation instructions: Helm Docs.

## Installation Steps

**1. Add the XkOps Helm Repository:**

Open your terminal and execute the following command to add the XkOps Helm repository:

```
helm repo add xkops https://xgridinc.github.io/xkops/charts/stable
```

**2. Obtain the Default values.yaml**

A default values.yaml file containing pre-configured settings for XkOps is available at XkOps values.yaml. Download this file and customize it according to your specific requirements.

**3. Customize the values.yaml (Optional)**

Open the downloaded values.yaml file in a text editor. Review and modify the parameters as needed. Refer to the XkOps documentation for detailed explanations of each parameter.

**Note:** This step is optional. If you're satisfied with the default settings, you can proceed to the next step.

**4. Install XkOps with Helm**

Run the following Helm command to install XkOps in your Kubernetes cluster:

```
helm install my-xkops xkops/xkops -f values.yaml
```

Replace my-xkops with your desired release name for the XkOps deployment.

**5. Verification**

Once the installation is complete, verify the successful deployment of XkOps components by checking the status of the pods:

```
kubectl get pods
```

This command will display a list of pods running in your cluster. Look for pods with names related to XkOps. The status of these pods should be "Running" to indicate a successful installation.

## Additional Considerations

- Refer to the XkOps documentation for detailed usage instructions, configuration options, and troubleshooting steps.

- Consider using a configuration management tool like Ansible or Puppet to manage complex deployments and values.yaml configuration in large environments.

- For security reasons, avoid storing sensitive information directly in the values.yaml file. Utilize environment variables or Kubernetes Secrets for sensitive data.

## Next Steps

With XkOps successfully installed, you can leverage its features to manage your Kubernetes cluster configurations. Explore the XkOps documentation for in-depth information on configuration options and usage examples.

## Support:

For further assistance or troubleshooting, refer to the XkOps documentation or contact the XkOps support team.