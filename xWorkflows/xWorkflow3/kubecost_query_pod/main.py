import requests
from pymongo import MongoClient
import os

# Environment Variables
MONGO_USERNAME = os.getenv("MONGO_USERNAME")
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")
MONGO_HOST = os.getenv("MONGO_HOST")
MONGO_PORT = os.getenv("MONGO_PORT")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")
MONGO_COLLECTION_NAME = os.getenv("MONGO_COLLECTION_NAME")
ROBUSTA_URL = os.getenv("ROBUSTA_URL")

# Get the list of Abandoned Workloads from Kubecost API
def getAbandonendWorkloads():
    api_endpoint = ROBUSTA_URL
    params = {
        "days": 2,
        "threshold": 500,
        "filter": ""  # Replace with actual filter if needed
    }

    try:
        response = requests.get(api_endpoint, params=params)
        response.raise_for_status()  # Raises HTTPError for bad responses
        response_json = response.json()
        abandonendWorkloads = [
            {
                "pod": item['pod'],
                "namespace": item['namespace'],
                "owners": item['owners']
            } 
            for item in response_json
        ]
        return abandonendWorkloads
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return []

def insert_pods_to_mongodb(abandonendWorkloads):
    try:
        client = MongoClient(f"mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}") 
        db = client[MONGO_DB_NAME]  # Replace with your database name
        collection = db[MONGO_COLLECTION_NAME]  # Replace with your collection name
        print("Searching for Abandoned Workloads")
        for abandonendWorkload in abandonendWorkloads:
            # Check if the pod is part of a deployment
            collection.insert_one(abandonendWorkload)
    except Exception as e:
        print(f"Failed to insert pods into MongoDB: {e}")

if __name__ == "__main__":
    abandonendWorkloads = getAbandonendWorkloads()
    if abandonendWorkloads:
        print(abandonendWorkloads)
        insert_pods_to_mongodb(abandonendWorkloads)


