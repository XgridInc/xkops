
# Unclaimed Volumes Remediation Workflow
This remediation workflow polls the Kubecost service for unclaimed volumes and deletes them using Robusta. Against every persistent volume which is unclaimed, xKops provides a button for the user to immediately delete it. If the volume is still unclaimed even after an hour, xKops deletes it. the deletion process is initiated by sending a POST request to robusta service through a webhook, which triggers the action to delete the persistent volumes.

## Getting All Available volumes
To obtain the unclaimed volumes, we send request to Kubecost AllPersistientVolumes API, which returns a JSON-formatted stream of data. After filtering the response, we retrieve a list of all available persistent volumes.

## Identifying Unclaimed Volumes
To identify the unclaimed volumes, we check the status of each persistent volume. If the status is "Available" then the volume is unbound and unclaimed, and can be safely deleted.







## Workflow Diagram

![Unclaimed Volumes](https://user-images.githubusercontent.com/107911263/235850432-cdbf80ec-55f1-4893-b9d0-1eb86a19c9dc.jpg)


