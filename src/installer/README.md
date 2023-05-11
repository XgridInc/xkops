# Installers

## Kubecost Installer

This script is used to install Kubecost, a tool for analyzing and managing Kubernetes costs, in a Kubernetes cluster. The script is written in Bash and automates the installation process using Helm, a package manager for Kubernetes.

### Kubecost Installation Steps

The script performs the following steps to install Kubecost:

1. Sources the `kc-config.sh` and `common-functions.sh` files from the `/src` directory. These files contain configuration settings and common functions used by the script.

2. Defines a function called `kc_installer()` which is the main installer function for Kubecost. This function checks if Kubecost is already deployed in the cluster by querying the Kubernetes deployment for the `kubecost-cost-analyzer` deployment. If the deployment is found, the function logs an info message and exits with a status code of 0. Otherwise, the function logs an error message and proceeds with the installation.

3. Inside the `kc_installer()` function, the script adds the Kubecost Helm repository using the `helm repo add` command, and then installs Kubecost using the `helm install` command. The Helm chart used for installation is `kubecost/cost-analyzer` and the release name is set to `kubecost` in the `kubecost` namespace.

4. After the installation, the function waits for the `kubecost prometheus-server` pod to be in a `Ready` condition using the `kubectl wait` command with a timeout of 1 hour.

5. Once the `kubecost prometheus-server` pod is ready, the function calls another function called `create_kc_service()` to create a Kubernetes service for Kubecost. This service exposes the `kubecost-cost-analyzer` deployment as a LoadBalancer service on port 80, targeting port 9090.

6. The `create_kc_service()` function uses the `kubectl expose` command to create the service.

7. Finally, the script calls the `kc_installer()` function to start the installation process.

## Robusta Installer

This Bash script installs Robusta in a Kubernetes cluster using Helm. Robusta is an open-source tool used for remediation and mitigation of security vulnerabilities in Kubernetes clusters.

### Robusta Installation Steps

1. Import configuration variables and common functions using the `source` command.
2. Print a prompt to the user using the `print_prompt()` function to initiate the installation of Robusta in the cluster.
3. Install Robusta using Helm by running the `rb_installer()` function, which performs the following tasks:
    - Adds the Robusta Helm repository using `helm repo add` command.
    - Updates the Helm repository using `helm repo update` command.
    - Installs Robusta chart using `helm install` command with custom values from `generated_values.yaml` file and creates a Kubernetes namespace called `robusta`.
    - Waits for the `robusta-runner` and `robusta-forwarder` deployments to be available in the `robusta` namespace using `kubectl wait` command with a timeout of 1 hour.
    - Calls the `watch_runner_logs()` function to watch the logs of `robusta-runner` pod and waits for the actions to be loaded.
    - Logs a success message when Robusta is successfully installed.
4. Loads Robusta custom remediation actions by running the `load_playbook_actions()` function, which performs the following tasks:
    - Logs a message to indicate the loading of playbook actions.
    - Pushes the playbook actions from the specified playbook directory using `robusta playbooks push` command with the `robusta` namespace.
    - Logs a success message when playbook actions are loaded.
5. Exits the script with a status code of 0.

## Pixie Installer

This Bash script installs Pixie, a tool used for monitoring and observability in a containerized environment using Helm. Helm is a package manager for Kubernetes that allows for easy deployment of applications as Helm charts.

### Pixie Installation Steps

The main installation process is done through the `px_installer()` function in the script. This function performs the following steps:

1. Installs the Pixie binary on the container by running the `install.sh` script with the `bash` command and passing "y" as an input to automatically confirm the installation. The `&>/dev/null` redirects the output to null, so there is no console output.
2. Sets up the Helm repository for Pixie by adding the `pixie-operator` repository and updating the Helm repository.
3. Installs Pixie using Helm by running the `helm install` command with the `pixie-operator/pixie-operator-chart` chart and passing the `PX_DEPLOY_KEY` and `clusterName` as parameters. The `--namespace` flag specifies the namespace for the installation and `--create-namespace` creates the namespace if it doesn't exist.
4. Validates the deployment of Pixie components in three namespaces (`OLMNS`, `PXOPNS`, and `PLNS`) using the `validate_healthy_deployment()` function.
5. Checks the status of the Pixie Vizier using a while loop and the `px get viziers` command with the `jq` tool to parse the JSON output. It waits until the Vizier status is "1", indicating that Pixie has been deployed successfully.
6. Logs a success message and exits with status code 0.

Note: The specific values for `PX_DEPLOY_KEY` and `clusterName` may need to be adjusted based on the environment and requirements of the installation.
