# Common Functions

This bash script contains a collection of common functions that can be used by other bash scripts. The functions provided in this script perform various tasks such as logging messages, checking if Helm is installed in the cluster, installing Helm if it is not installed, checking permissions for a service account, and verifying the status of pods in a namespace.

## Functions

### log()

This function is used to log messages with a timestamp, log level, function name, and message. The logged messages are saved in the `/tmp/app.log` file. The parameters for this function are:

- `level`: Type of log level, which can be ERROR, PASSED, or INFO.
- `function`: Name of the script or function from which the log is coming.
- `message`: Message to be logged.

### log_test()

Similar to the `log()` function, this function is used to log messages with a timestamp, log level, function name, and message. However, the logged messages are saved in the `/tmp/app_test.log` file instead of `/tmp/app.log`.

### helm_checker()

This function checks if Helm is installed in the cluster. If Helm is not installed, it calls the `helm_installer()` function to download and install Helm.

### helm_installer()

This function downloads the Helm 3 binary using `curl` and installs it on the system. It also checks if Helm is installed successfully and logs the result.

### check_permissions()

This function checks if the service account has permissions to list deployments in the Kubernetes cluster. It uses `curl` to send a request to the Kubernetes API server and checks the response for any Forbidden error messages. If the service account does not have the necessary permissions, the script terminates with an error message.

### pod_status_verifier()

This function verifies the status of pods in the specified namespaces. It takes a list of namespaces as input and checks if the namespaces exist. If a namespace exists, it retrieves the list of pods in that namespace and iterates over each pod to check its status. If a pod is not in the Running or Completed state, an error message is logged.
