This document outlines the different methods for configuring XkOps using Helm parameters. These parameters allow you to customize the deployment behavior of XkOps to suit your specific needs.

Understanding Helm Parameters

Helm charts offer a way to package Kubernetes applications and their configurations. XkOps utilizes a values.yaml file to store default configuration values for the deployed components. These values can be overridden during installation using Helm parameters.

Passing Helm Parameters

There are two primary methods for passing Helm parameters when installing XkOps:

Using Command-Line Flags ( --set )

This approach allows you to directly specify individual parameters while executing the Helm install command. Here's an example:

helm install my-xkops xkops/xkops \
  --repo https://xgridinc.github.io/xkops/charts/stable \
  --namespace xkops \
  --create-namespace \
  --set cluster.name={{CLUSTER_NAME}} \
  --set apiServer.serviceClusterIPRange={{SERVICE_CLUSTER_IP_RANGE}}

In this example, we set the cluster name to and specify a custom service cluster IP range using the apiServer.serviceClusterIPRange parameter.

Customizing the values.yaml file

You can modify the default values.yaml file downloaded from the provided location (link can be added later) to customize various parameters. This approach allows for more complex configurations and avoids cluttering the install command with numerous flags.

Here's a basic example structure of a modified values.yaml file:

cluster:
  name: {{CLUSTER_NAME}}
apiServer:
  serviceClusterIPRange: {{SERVICE_CLUSTER_IP_RANGE}}

Once the values.yaml file is customized, use the following command to install XkOps with your specific configuration:

helm install my-xkops xkops/xkops \
    --repo https://xgridinc.github.io/xkops/charts/stable \
    --namespace xkops \
    --create-namespace \
    -f values.yaml

Choosing the Right Method:

Simple Configuration: For setting a few specific parameters, using command-line flags offers a concise approach.

Complex Configuration: For extensive customization or managing multiple XkOps deployments with different configurations, modifying the values.yaml file is more efficient.