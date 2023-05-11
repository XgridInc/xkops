
# Kubecost Checker

This bash script is used to check the presence of Kubecost in a Kubernetes cluster. It verifies the configuration of `kubectl`, and then uses `kubectl` or `curl` to check the existence of Kubecost namespace, deployment, and image in the cluster.

## Components of Kubecost Checker

This script consists of several functions that are called sequentially to check the presence of Kubecost in the Kubernetes cluster. Each function performs a specific check and provides feedback on the results.

### `check_kubectl()`

This function checks if `kubectl` is configured or not. If `kubectl` is configured, it calls the `kubectl_kc_checker` function. Otherwise, it calls the `curl_kc_checker` function.

### `kubectl_kc_checker()`

This function checks the presence of Kubecost namespace, deployment, and image in the Kubernetes cluster using `kubectl` utility. It calls the following functions sequentially:

- `kubectl_kcNS_checker()`: This function checks if the Kubecost namespace is found in the cluster.
- `kubectl_kcDeploy_checker()`: This function checks if the Kubecost deployment is found in the cluster.
- `kubectl_kcImage_checker()`: This function checks the correctness of the Kubecost deployment image.

### `kubectl_kcNS_checker()`

This function uses `kubectl` to find the Kubecost namespace in the cluster. If the namespace is found, it displays a success message. Otherwise, it displays an error message and exits the script with status code 0.

### `kubectl_kcDeploy_checker()`

This function uses `kubectl` to find the Kubecost deployment in the cluster. If the deployment is found, it displays a success message. Otherwise, it displays an error message and exits the script with status code 0.

### `kubectl_kcImage_checker()`

This function uses `kubectl` to get the image used by the Kubecost deployment in the cluster. It checks if the image matches the expected image. If the image is correct, it displays a success message. Otherwise, it displays an error message and exits the script with status code 0.

### `curl_kc_checker()`

This function is called when `kubectl` is not configured. It uses `curl` to access the Kubernetes API server and retrieve the list of deployments. It then checks the correctness of the Kubecost deployment name and image in the retrieved data. If Kubecost is found, it displays a success message. Otherwise, it displays an error message and exits the script with status code 0.

# Robusta Checker

This Bash script is used to check if the Robusta deployment is installed in your Kubernetes cluster. It performs checks by querying the cluster using `kubectl` or `curl` commands to verify the presence of expected deployments and images.

## Components of Robusta Checker

The script has two main functions:

1. `kubectl_rb_checker()`: This function checks for the presence of Robusta deployments and images using `kubectl` commands.
2. `curl_rb_checker()`: This function checks for the presence of Robusta deployments and images using `curl` commands.

### `kubectl_rb_checker()`

This function performs the following steps:

1. Sets the list of expected deployment names and image names to check.
2. Gets the list of namespaces in the cluster using `kubectl` command.
3. Iterates through each namespace.
4. Gets the list of deployments in each namespace.
5. Iterates through each deployment in each namespace.
6. Iterates through each expected deployment name and image name.
7. Checks if the deployment name and image name match the expected values.
8. If the deployment and image are found, it gets the status of pods in the deployment.
9. Checks if any of the pods are not in the "Running" state.
10. Prints an error message if the deployment or image is not found or the pods are not in the "Running" state.
11. Exits with error code 1 if Robusta is found in the cluster.

### `curl_rb_checker()`

This function performs the following steps:

1. Gets the list of namespaces in the cluster using `curl` command.
2. Extracts the names of the namespaces from the JSON response.
3. Iterates through the namespaces.
4. Checks if the "robusta-runner" deployment exists in the namespace using `curl` command.
5. Extracts the image for the "robusta-runner" deployment from the JSON response.
6. Checks if the image matches the expected image name.
7. Gets the list of pods for the "robusta-runner" deployment using `curl` command.
8. Checks if any of the pods are not in the "Running" state.
9. Sets the `runner_found` flag if the "robusta-runner" deployment and image are found.
10. Performs similar checks for the "robusta-forwarder" deployment and sets the `forwarder_found` flag if found.
11. Prints an error message if the deployment or image is not found or the pods are not in the "Running" state.
12. Exits with error code 1 if Robusta is found in the cluster.

# Pixie Checker

This Bash script, named `px_checker.sh`, is used to detect the presence of Pixie in a Kubernetes cluster. It performs a series of checks to verify the existence of Pixie namespaces and deployments using `kubectl` and `curl` commands. If any of the Pixie components are not found, the script exits with an appropriate exit code.

## Components of Pixie Checker

The `px_checker.sh` script consists of the following functions:

### `check_permissions()`

This function checks whether the service account running the script has the necessary permissions to list deployments in the cluster.

### `kubectl_pxNS_checker()`

This function checks for the existence of Pixie namespaces using the `kubectl` command. If `kubectl` is unable to reach the Kubernetes API server, it falls back to using `curl` to directly query the API server. If any of the Pixie namespaces (`$OLMNS`, `$PXOPNS`, `$PLNS`) are not found, the script exits with a non-zero exit code, indicating that Pixie was not detected in the cluster.

### `curl_pxNS_checker()`

This function uses `curl` to directly query the Kubernetes API server for the existence of Pixie namespaces. It iterates through an array of namespaces (`$OLMNS`, `$PXOPNS`, `$PLNS`) and checks if each namespace is present. If any of the Pixie namespaces are not found, the script exits with a non-zero exit code, indicating that Pixie was not detected in the cluster.

### `kubectl_pxDeploy_checker()`

This function checks for the existence of Pixie deployments in the Pixie namespaces using the `kubectl` command. It retrieves the list of deployments in the `$PLNS` and `$OLMNS` namespaces, and checks if the expected deployments (`$PL_KELVIN`, `$PL_CLOUD_CONNECTOR`, `$PL_VIZIER_QUERY_BROKER`, `$OLM_CATALOG_OPERATOR`, `$OLM_OPERATOR`) are present. If any of the deployments are not found, the script logs an information message and continues to the next deployment. If all expected deployments are found, the script exits with a non-zero exit code, indicating that Pixie was detected in the cluster.
