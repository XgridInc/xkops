# Preflights

## Kubecost Preflight

This Bash code is used to initiate pre-flight checks for Kubecost installation to a K8s cluster. The code checks if kubectl is installed in the cluster, installs kubectl if not configured, and proceeds to execute other pre-flight checks.

### Kubecost Preflight Functions

#### `kubectl_checker()`

This function is defined to check if kubectl is installed in the K8s cluster or not. If kubectl is not configured, the function calls the `kubectl_installer()` function to install kubectl in the K8s cluster.

#### `kubectl_installer()`

This function is defined to install kubectl in the K8s cluster. It downloads the latest release of kubectl, installs it, creates a new directory for the binary, and adds kubectl to the PATH.

## Robusta Preflight

This script is a bash script that performs pre-flight checks for installing Robusta in a cluster. It checks for a generated_values.yaml file and generates it if it does not exist. The script also checks if Robusta CLI is installed and installs it if it is not. It ends with a check for the default storage class of the cluster and unpatches it if it has been patched before.

### Robusta Preflight Functions

#### `check_values_file`

This function checks for the existence of a generated_values.yaml file in the pre-flight directory. If the file exists, the function logs a message that the file was found. If the file does not exist, the function calls the `rb_cli_checker` function to check if Robusta CLI is installed. If it is installed, the function generates the `generated_values.yaml` file using the `generate_values_file` function. If it is not installed, the function logs an error message and exits the script.

#### `rb_cli_checker`

This function checks if Robusta CLI is installed by verifying the presence of the `robusta` command. If it is installed, the function logs an informational message that Robusta CLI is installed along with its version. If it is not installed, the function calls the `rb_cli_installer` function to install it. If the installation is successful, the function logs an informational message that Robusta CLI is installed along with its version. If it is not successful, the function logs an error message and exits the script.

#### `rb_cli_installer`

This function installs Robusta CLI by first checking if pip3 is installed. If it is installed, the function installs Robusta CLI using pip3. If pip3 is not installed, the function installs it and then installs Robusta CLI using pip3. If the installation is successful, the function returns. If it is not successful, the function logs an error message and exits the script.

#### `generate_values_file`

This function generates a `generated_values.yaml` file in the pre-flight directory using the `robusta gen-config` command. The function takes a filename as a parameter, which is used as the output path of the generated `generated_values.yaml` file. The function also enables the persistent volume in the `generated_values.yaml` file by adding the line `playbooksPersistentVolume: true` to the file if it is not already present.

## Pixie Preflight

This Bash script is designed to perform pre-flight checks for installing the Pixie tool on a Kubernetes cluster. It includes several functions and uses various commands to perform checks for Kubernetes version, Linux kernel version, CPU architecture, and available memory.

### Pixie Preflight Functions

#### `preFlight_checks`

The `preFlight_checks()` function contains several checks to ensure that the Kubernetes cluster meets the requirements for Pixie installation. These checks are as follows:

1. Kubernetes Version Check: The function checks the version of Kubernetes installed on the cluster. It does this by sending a request to the Kubernetes API server and parsing the response to extract the version. If the version is less than 1.21, the function exits with an error message.
2. Linux Kernel Version Check: The function checks the version of the Linux kernel installed on the node. It does this by using the `uname` command to get the kernel version and comparing it to the required version of 4.14+. If the version is less than 4.14, the function exits with an error message.
3. CPU Check: The function checks the architecture of the CPU. It does this by using the `lscpu` command to get the architecture and comparing it to the required architecture of x86_64. If the architecture is not x86_64, the function exits with an error message.
4. Memory Check: The function checks the amount of free memory available on the node. It does this by using the `free` command to get the amount of free memory and comparing it to the required amount of 1Gi per node. If the available memory is less than 1Gi, the function exits with an error message.
