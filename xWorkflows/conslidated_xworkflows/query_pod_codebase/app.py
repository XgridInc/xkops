import yaml
import requests
from pymongo import MongoClient
import os

def connectToMongoDB(hostname, port, username, password, databaseName, collectionName):
    """
    Connect to a MongoDB instance and access the specified collection.

    Args:
        hostname (str): The hostname of the MongoDB server.
        port (int): The port on which MongoDB is running.
        username (str): The username for MongoDB authentication.
        password (str): The password for MongoDB authentication.
        databaseName (str): The name of the MongoDB database.
        collectionName (str): The name of the collection to access.

    Returns:
        pymongo.collection.Collection: The MongoDB collection object if the connection is successful.
        None: If an error occurs while connecting.
    """
    try:
        client = MongoClient(host=hostname, port=port, username=username, password=password)
        db = client[databaseName]
        collection = db[collectionName]
        return collection
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

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
    # Add more URLs and parameters as needed
}

def readWorkflowDefinitions(filePath):
    """
    Read and parse a YAML file containing workflow definitions.

    This function reads the YAML file specified by `filePath`, parses its content,
    and prints out the number of workflows found along with each workflow's name.
    It also returns the parsed YAML data as a dictionary.

    Args:
        filePath (str): The path to the YAML file to be read.

    Returns:
        dict: A dictionary representing the parsed YAML content if the file is read successfully.
              The dictionary includes a list of workflows and their details.
        None: If an error occurs during file reading or parsing, indicating that the data could not be retrieved.
    
    Prints:
        - The total number of workflows found in the YAML file.
        - The name of each workflow found in the YAML file.

    """
    try:
        with open(filePath, 'r') as file:
            data = yaml.safe_load(file)
            # Retrieve and print the number of workflows and their names
            workflows = data.get('workflows', [])
            print(f"Found {len(workflows)} workflows")
            for workflow in workflows:
                print(f"Workflow Name: {workflow.get('name')}")
            return data
    except Exception as e:
        print(f"Error reading YAML file: {e}")
        return None



def fetchData(url, params):
    """
    Fetch data from a REST API.

    Args:
        url (str): The URL of the API endpoint.
        params (dict): The parameters to include in the API request.

    Returns:
        dict: The JSON response from the API if the request is successful.
        None: If the request fails or the response status code is not 200.
    """
    response = requests.get(url, params=params)
    if response.status_code == 200:
        return response.json()  # If the response is in JSON format
    else:
        print(f"Failed to retrieve data from {url}: {response.status_code}")
        return None

def main():
    """
    Main function to connect to MongoDB, fetch data from APIs, and insert data into MongoDB collections based on workflows.

    Environment Variables:
        - MONGODB_HOSTNAME (str): The hostname of the MongoDB server.
        - MONGODB_USERNAME (str): The username for MongoDB authentication.
        - MONGODB_PASSWORD (str): The password for MongoDB authentication.
        - MONGODB_DATABASE (str): The name of the MongoDB database.
    """
    hostname = os.getenv('MONGODB_HOSTNAME')
    port = 27017 
    username = os.getenv('MONGODB_USERNAME')
    password = os.getenv('MONGODB_PASSWORD')
    databaseName = os.getenv('MONGODB_DATABASE')
    collectionVolume = "collection_volume"  # for storing volume data
    collectionNodes = "collection_nodes"  # for storing nodes data

    filePath = '/app/config/values.yaml'
    workflowsDict = readWorkflowDefinitions(filePath)

    if not workflowsDict:
        print("No workflows found or failed to read the YAML file.")
        return
    
    for workflow in workflowsDict.get('workflows', []):
        name = workflow.get('name')
        dataSource = workflow.get('dataSource')
        scrapeData = workflow.get('scrapeData')

        if dataSource == "kubecost" and scrapeData == "nodes":
            """
            Set up a scraper for node data from the Kubecost API and insert data into MongoDB.

            This process involves:
            - Connecting to the MongoDB collection for nodes.
            - Fetching node data from the specified API endpoint.
            - Processing and inserting the fetched node data into the MongoDB collection.

            Workflow Details:
            - Name: {name}
            - Data Source: {dataSource}
            - Scrape Data: {scrapeData}
            """
            collectionForNodeData = connectToMongoDB(hostname, port, username, password, databaseName, collectionNodes)

            if collectionForNodeData is not None:
                print("Successfully connected to the collectionForNodeData!")
            else:
                print("Failed to connect to the collectionForNodeData.")

            print(f"Setting up scraper for Workflow: {name}, Data Source: {dataSource}, Scrape Data: {scrapeData}")
            response = fetchData(urlsAndParams['nodeUrl']['url'], urlsAndParams['nodeUrl']['params'])
            if response and response.get("code") == 200:
                for nodesData in response.get("data", []):
                    for key, value in nodesData.items():
                        nodeData = {
                            'name': value['properties']['name'],
                            'start': value['start'],
                            'end': value['end'],
                            'minutes': value['minutes'],
                            'nodeType': value['nodeType'],
                            'ramBytes': value['ramBytes'],
                            'cpuCores': value['cpuCores'],
                            'totalCost': value['totalCost']
                        }
                        try:
                            collectionForNodeData.insert_one(nodeData)
                        except KeyError as e:
                            print(f"KeyError: {e} in data item {nodesData}")

        elif dataSource == "kubecost" and scrapeData == "unclaimedvolume":
            """
            Set up a scraper for unclaimed volume data from the Kubecost API and insert data into MongoDB.

            This process involves:
            - Connecting to the MongoDB collection for volumes.
            - Fetching unclaimed volume data from the specified API endpoint.
            - Processing and inserting the fetched volume data into the MongoDB collection.

            Workflow Details:
            - Name: {name}
            - Data Source: {dataSource}
            - Scrape Data: {scrapeData}
            """
            collectionForVolumeData = connectToMongoDB(hostname, port, username, password, databaseName, collectionVolume)

            if collectionForVolumeData is not None:
                print("Successfully connected to the collectionForVolumeData!")
            else:
                print("Failed to connect to the collectionForVolumeData.")

            print(f"Setting up scraper for Workflow: {name}, Data Source: {dataSource}, Scrape Data: {scrapeData}")
            response = fetchData(urlsAndParams['unclaimedVolUrl']['url'], urlsAndParams['unclaimedVolUrl']['params'])
            if response and response.get("code") == 200:
                for volume in response.get("data", {}).get("volumes", []):
                    volumeData = {
                        'provider': volume["properties"]["provider"],
                        'name': volume["properties"]["name"],
                        'cluster': volume["properties"]["cluster"],
                        'monthlyCost': volume["monthlyCost"]
                    }
                    try:
                        collectionForVolumeData.insert_one(volumeData)
                    except KeyError as e:
                        print(f"KeyError: {e} in data item {volume}")


if __name__ == "__main__":
    main()
