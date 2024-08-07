from flask import Flask, jsonify, request
from pymongo import MongoClient
import requests
import pymongo
import os 

app = Flask(__name__)

# Environment Variables
MONGO_USERNAME = os.getenv("MONGO_USERNAME")
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD")
MONGO_HOST = os.getenv("MONGO_HOST")
MONGO_PORT = os.getenv("MONGO_PORT")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME")
MONGO_COLLECTION_NAME = os.getenv("MONGO_COLLECTION_NAME")
ROBUSTA_URL = os.getenv("ROBUSTA_URL")

# Connect to MongoDB
client = MongoClient(f"mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}")

# Accessing the db
def get_db():
    try:
        db = client[MONGO_DB_NAME]
        return db
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error accessing database"}), 500

# Accessing the collection
def get_collection():
    try:
        db = get_db()  # Reuse the database access logic
        collection = db[MONGO_COLLECTION_NAME]
        return collection
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error accessing collection"}), 500

# List the Deployments with Abandoned Workloads
@app.route('/deployments', methods=['GET'])
def get_deployments():
    try:
        collection = get_collection()  # Use the function to access collection and client
        deployments = list(collection.find({}, {'_id': 0, 'owners': 1}))

        # Filter out entries with empty owner name or kind
        filteredDeployments = [deployment for deployment in deployments if all(owner.get('name') and owner.get('kind') for owner in deployment.get('owners', []))]

        return jsonify(filteredDeployments)
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error fetching deployments"}), 500

# Delete the Deployment with Abandoned Workload
@app.route('/deployments/delete/<deployment_name>', methods=['POST'])
def delete_deployments(deployment_name):
    print("The name of the Deployment is:", deployment_name)
    data = request.get_json()
    deployment_namespace = data.get("namespace")
    try:
        payload = {
            "action_name": "deleteDeployment",
            "action_params": {"name": deployment_name, "namespace": deployment_namespace},
        }
        headers = {"Content-Type": "application/json"}
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()  # Raise exception for non-2xx status codes

        # Update PV status in MongoDB (optional for informational purposes)
        with MongoClient(f"mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}") as client:
            db = client[MONGO_DB_NAME]
            col = db[MONGO_COLLECTION_NAME]
            col.update_one({"name": deployment_name}, {"$set": {"status": "deleted"}})  # Update only if necessary

        return jsonify({"message": "Deployment deletion initiated"})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Error from Robusta API: {e}"}), e.response.status_code
    except pymongo.errors.PyMongoError as e:
        return jsonify({"error": f"MongoDB error: {e}"}), 500
    except Exception as e:  # Catch other unexpected errors
        return jsonify({"error": "Internal server error"}), 500
    
# Resize the Deployment with Abandoned Workloads by changing the replicas 
@app.route('/deployments/replicasresize/<deploymentName>', methods=['POST'])
def resize_deployments(deploymentName):
    print("The name of the Deployment is:", deploymentName)
    data = request.get_json()
    deploymentNamespace = data.get("namespace")
    updatedReplicas = data.get("replicas")
    try:
        payload = {
            "action_name": "resizeDeploymentReplicaCount",
            "action_params": {"name": deploymentName, "namespace": deploymentNamespace, "replicas": updatedReplicas},
        }
        headers = {"Content-Type": "application/json"}
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()  # Raise exception for non-2xx status codes

        # Update PV status in MongoDB (optional for informational purposes)
        with MongoClient(f"mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}") as client:
            db = client[MONGO_DB_NAME]
            col = db[MONGO_COLLECTION_NAME]
            col.update_one({"name": deploymentName}, {"$set": {"status": "Resized"}})  # Update only if necessary

        return jsonify({"message": "Deployment resizing initiated"})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Error from Robusta API: {e}"}), e.response.status_code
    except pymongo.errors.PyMongoError as e:
        return jsonify({"error": f"MongoDB error: {e}"}), 500
    except Exception as e:  # Catch other unexpected errors
        return jsonify({"error": "Internal server error"}), 500
# Get the pods 
@app.route('/pods', methods=['GET'])
def get_pods():
    try:
        collection = get_collection()  # Use the function to access collection
        pods = list(collection.find({}, {'_id': 0}))
        return jsonify(pods)
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error fetching pods"}), 500

# Delete the pod 
@app.route('/pods/delete/<pod_name>', methods=['POST'])
def delete_pods(pod_name):
    print("The name of the Pod is:", pod_name)
    data = request.get_json()
    pod_namespace = data.get("namespace")
    try:
        payload = {
            "action_name": "deletePod",
            "action_params": {"name": pod_name, "namespace": pod_namespace},
        }
        headers = {"Content-Type": "application/json"}
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()  # Raise exception for non-2xx status codes

        # Update PV status in MongoDB (optional for informational purposes)
        with MongoClient(f"mongodb://{MONGO_USERNAME}:{MONGO_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}") as client:
            db = client[MONGO_DB_NAME]
            col = db[MONGO_COLLECTION_NAME]
            col.update_one({"name": pod_name}, {"$set": {"status": "deleted"}})  # Update only if necessary

        return jsonify({"message": "Pod deletion initiated"})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Error from Robusta API: {e}"}), e.response.status_code
    except pymongo.errors.PyMongoError as e:
        return jsonify({"error": f"MongoDB error: {e}"}), 500
    except Exception as e:  # Catch other unexpected errors
        return jsonify({"error": "Internal server error"}), 500

# Health check endpoint
@app.route('/health')
def health():
    return jsonify({"status": "OK"}), 200  # Simple JSON response with 200 status code

@app.route('/')
def home():
    return "Welcome to the Flask API!"

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
