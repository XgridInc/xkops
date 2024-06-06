# Helmfile Configuration for Robusta, Pixie, and Kubecost
This project provides a Helmfile configuration for deploying Robusta, Pixie, and Kubecost on a Kubernetes cluster. It streamlines the installation process and leverages hooks for additional configuration tasks.

## Key Features
- Installs Robusta, Pixie, and Kubecost using Helmfile.
- Utilizes hooks for pre-installation configuration.
- Provides a user-friendly experience for deploying these tools.

## Requirements
- A running Kubernetes cluster
- Helm installed on your system. Follow this [guide](https://helm.sh/docs/intro/install/) to install helm. 
- A Slack account and a dedicated Slack channel for Robusta

## Generating a Slack API Key
If you are using a private channel for robsuta sink you can create a custom app to get slack-api-key. Follow this [guide](https://docs.robusta.dev/master/configuration/sinks/slack.html) to create a custom app with required permissions. You also need to add the app in you channel.

## Configure values.yaml
- Locate the values.yaml file within your Helm chart directory named helm-charts.
- Edit this file and update the following values with your information:
  - **slack_api_key**: Your Slack API key
  - **slack_channel_name**: The name of your dedicated Slack channel for Robusta
  - **cluster_name**: Your Kubernetes cluster name
  - **generated_values_path**: The path where generated_values.yaml will be created.

## Update values.yaml:
Update any additional values you want to add or update in the values.yaml file as needed.

## Open and Edit the Helmfile Configuration
Open the provided Helmfile configuration file located in the helm-file folder. You can easily pick which tools to install by setting the installed value to true or false.

## Execute the install-helmfile script
Locate the install-helmfile.sh script within the scripts folder. Run this script with appropriate permissions. It will:

- Install Helmfile if it is not installed already.
- Set necessary permissions for Helmfile and hooks.
- Configure Helmfile in /usr/local/bin.
- Execute the helmfile sync command.

The helmfile sync command processes the configuration, runs any defined hooks including the Robusta prepare hook for generating generated_values.yaml, and installs the chosen tools in their respective namespaces.

## References

- [Helm](https://helm.sh/)
- [Helmfile](https://helmfile.readthedocs.io/)
- [Robusta](https://home.robusta.dev/)
- [Pixie](https://px.dev/)
- [Kubecost](https://www.kubecost.com/)
- [Slack](https://slack.com/)
- [Slack API Page](https://api.slack.com/web)

