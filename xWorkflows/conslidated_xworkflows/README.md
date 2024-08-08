

# Consolidated xWorkflow



## Overview

The Consolidated xWorkflow simplifies the process of defining and managing sworkflows by allowing users to specify them in a straightforward YAML configuration file. The **query_pod** application, which is central to this system, interfaces with various Kubecost APIs to fetch relevant data. This data is then  stored in MongoDB according to the workflows outlined in the configuration file. This setup reduces the need for technical expertise and streamlines the xworkflow configuration process for end user.

## Kubernetes Configuration

The Kubernetes configuration includes several components for deploying the query pod and MongoDB. These configurations are located in the `k8s_yaml_files` directory.

### Kubernetes YAML Files

1. **`mongodb-headless-service.yaml`**: Defines a headless service for MongoDB to enable stable network identities and facilitate StatefulSet communication.
2. **`mongodb-statefulset.yaml`**: Configures the MongoDB StatefulSet, including initialization parameters and storage.
3. **`query-pod-deployment.yaml`**: Specifies the deployment for the query pod, including environment variables, image details, and volume mounts.
4. **`workflow-configmap.yaml`**: Contains the configuration for the workflow definitions used by the query pod.
5. **`mongodb-secrets.yaml`**: Stores MongoDB credentials securely.

## Python Application (query_pod)

### Description

The `query_pod` application is a Python script (`app.py`) designed to:

1. **Read Workflow Definitions**: Load and parse a YAML file containing workflow configurations.
2. **Fetch Data**: Retrieve data from specified kubecost APIs based on workflow parameters.
3. **Store Data**: Insert the fetched data into MongoDB collections.

### Functionality

1. **Connecting to MongoDB**: Establishes a connection to the MongoDB instance using credentials provided as environment variables.
2. **Fetching Data**: Retrieves data from kubecost APIs using predefined URLs and parameters.
3. **Processing Workflows**: Iterates over workflows, sets up the scraper, and stores data accordingly.

## How to Setup

### Build Docker Image

1. Navigate to the `query_pod_codebase` directory where the `Dockerfile` is located.
2. Build the Docker image using the following command:
   ```sh
   docker build -t your-image-name:tag .
   ```

### Update Kubernetes YAML Files

1. Update the `query-pod-deployment.yaml` file with the new image name and tag.
2. Apply the updated YAML file to your Kubernetes cluster:
   ```sh
   kubectl apply -f k8s_yaml_files/query-pod-deployment.yaml
   ```

Here’s an enhanced section on how to add a new workflow to the README:

---

### Adding a New Workflow

To add a new workflow to the **query_pod** application, follow these steps:

#### 1. Define Workflow in `values.yaml`

Add the new workflow configuration to the `values.yaml` file in the `workflow-configmap.yaml` ConfigMap. For example:
```yaml
workflows:
- data_source: custom_source
  name: workflow4
  robusta_playbook: new_playbook
  scrape_data: new_data
```

#### Explanation of Workflow Fields

- **data_source**: This specifies the origin of the data you wish to retrieve. In our case, it is typically `kubecost`, but other sources can be added as the application evolves.
- **name**: The unique name of the workflow. This helps in identifying and managing different workflows.
- **robusta_playbook**: The associated Robusta playbook for this workflow. While this is a placeholder for now, it will be linked to specific playbooks in future updates.
- **scrape_data**: Indicates the specific type of data to be fetched from the data source. For `kubecost`, allowed values include `nodes`, `unclaimedvolume` and `containerResourceSizing`. As the application grows, more data types will be supported.

#### 2. Update URL and Parameters in `app.py`

In the `app.py` file, ensure that the appropriate URL and parameters for the new workflow are added to the `urlsAndParams` dictionary. For example:
```python
urlsAndParams = {
    'nodeUrl': {
        'url': "http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9090/model/assets",
        'params': {
            'window': '1w',
            'filter': 'assetType:\"node\"',
            'accumulate': 'true'
        }
    },
    'unclaimedVolUrl': {
        'url': "http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9090/model/savings/unclaimedVolumes",
        'params': {
            'window': '7d',
            'aggregate': 'provider',
            'accumulate': 'true'
        }
    },
    'newDataUrl': {
        'url': "http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9090/model/custom",
        'params': {
            'window': '1w',
            'filter': 'customFilter',
            'accumulate': 'true'
        }
    }
}
```
For detailed information on the APIs provided by Kubecost, developers can refer to the official documentation at [Kubecost API Overview](https://docs.kubecost.com/apis/apis-overview).

#### 3. Extend the Main Processing Loop

Add the corresponding logic for the new workflow within the main processing loop in the `main` function:
```python
for workflow in workflowsDict.get('workflows', []):
    name = workflow.get('name')
    dataSource = workflow.get('dataSource')
    scrapeData = workflow.get('scrapeData')

    if dataSource == "kubecost" and scrapeData == "nodes":
        # Existing logic for nodes

    elif dataSource == "kubecost" and scrapeData == "unclaimedvolume":
        # Existing logic for unclaimed volumes

    elif dataSource == "custom_source" and scrapeData == "new_data":
        """
        Set up a scraper for new data from the custom source API and insert data into MongoDB.

        This process involves:
        - Connecting to the MongoDB collection for new data.
        - Fetching new data from the specified API endpoint.
        - Processing and inserting the fetched new data into the MongoDB collection.

        Workflow Details:
        - Name: {name}
        - Data Source: {dataSource}
        - Scrape Data: {scrapeData}
        """
        collectionForNewData = connectToMongoDB(hostname, port, username, password, databaseName, "collection_new_data")

        if collectionForNewData is not None:
            print("Successfully connected to the collectionForNewData!")
        else:
            print("Failed to connect to the collectionForNewData.")

        print(f"Setting up scraper for Workflow: {name}, Data Source: {dataSource}, Scrape Data: {scrapeData}")
        response = fetchData(urlsAndParams['newDataUrl']['url'], urlsAndParams['newDataUrl']['params'])
        if response and response.get("code") == 200:
            for newDataItem in response.get("data", []):
                newData = {
                    'field1': newDataItem['field1'],
                    'field2': newDataItem['field2'],
                    # Add more fields as necessary
                }
                try:
                    collectionForNewData.insert_one(newData)
                except KeyError as e:
                    print(f"KeyError: {e} in data item {newDataItem}")

```
By following these steps, you can easily add new workflows to the **query_pod** application, enabling it to fetch and store data from additional sources as per need.

## Conclusion

The consolidated xWorkflow is designed to streamline the process of defining and managing data workflows in a Kubernetes environment. This setup minimizes the need for extensive technical expertise, allowing users to focus on defining their workflows in a straightforward YAML format. The application’s modular design ensures that adding new workflows is a simple and scalable process. As the project evolves, it will continue to incorporate more data sources and functionalities, making it an indispensable tool for data management in Kubernetes clusters.

By following the provided setup instructions and examples, you can efficiently deploy the query_pod application and start managing your workflows with ease. The detailed documentation ensures that both novice and experienced developers can get started quickly and customize the application to fit their specific needs.

For any further questions or contributions, please refer to the project's repository and documentation.