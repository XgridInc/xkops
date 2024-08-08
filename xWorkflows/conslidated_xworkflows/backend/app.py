from flask import Flask, jsonify, request
from pymongo import MongoClient
import os
import requests

app = Flask(__name__)
ROBUSTA_URL = "http://localhost:5000/api/trigger"

def connect_to_mongodb(collection_name):
    """
    Connects to a MongoDB database and returns a collection.

    Args:
        collection_name (str): The name of the collection to access.

    Returns:
        pymongo.collection.Collection: The requested MongoDB collection, or None if the connection fails.
    """    
    hostname = os.getenv('MONGODB_HOSTNAME')
    port = 27017
    username = os.getenv('MONGODB_USERNAME')
    password = os.getenv('MONGODB_PASSWORD')
    database_name = os.getenv('MONGODB_DATABASE')

    try:
        client = MongoClient(host=hostname, port=port, username=username, password=password)
        db = client[database_name]
        collection = db[collection_name]
        return collection
    except Exception as e:
        print(f"Error connecting to MongoDB: {e}")
        return None

@app.route('/nodes', methods=['GET'])
def get_nodes():
    """
    Retrieves all documents from the 'collection_nodes' collection in MongoDB.

    Returns:
        flask.Response: JSON response containing nodes data, or an error message if the collection is not accessible.
    """    
    collection = connect_to_mongodb('collection_nodes')
    if collection is not None:
        nodes = list(collection.find({}, {'_id': 0}))  # Omit the '_id' field from the response
        return jsonify(nodes)
    else:
        return jsonify({"error": "Could not connect to the nodes collection"}), 500

@app.route('/unclaimed_volumes', methods=['GET'])
def get_unclaimed_volumes():
    """
    Retrieves all documents from the 'collection_volume' collection in MongoDB.

    Returns:
        flask.Response: JSON response containing volumes data, or an error message if the collection is not accessible.
    """
    collection = connect_to_mongodb('collection_volume')
    if collection is not None:
        volumes = list(collection.find({}, {'_id': 0}))  # Omit the '_id' field from the response
        return jsonify(volumes)
    else:
        return jsonify({"error": "Could not connect to the volumes collection"}), 500

@app.route('/sizing_v2', methods=['GET'])
def get_sizing_v2():
    """
    Retrieves all documents from the 'collection_sizingv2' collection in MongoDB.

    Returns:
        flask.Response: JSON response containing sizing data, or an error message if the collection is not accessible.
    """    
    collection = connect_to_mongodb('collection_sizingv2')
    if collection is not None:
        sizing_data = list(collection.find({}, {'_id': 0}))  # Omit the '_id' field from the response
        return jsonify(sizing_data)
    else:
        return jsonify({"error": "Could not connect to the sizing_v2 collection"}), 500

def handle_action(action_name, action_params):
    """
    Handle the given action by making a POST request to the Robusta API.

    Args:
        action_name (str): The name of the action (e.g., 'podCpu', 'podMemory', 'deploymentCpu').
        action_params (dict): The parameters for the action.

    Returns:
        dict: The response from the Robusta API.
    """
    data = {
        "action_name": action_name,
        "action_params": action_params
    }
    response = requests.post(ROBUSTA_URL, json=data)
    
    if response.status_code == 200:
        return response.json()
    else:
        return {"error": f"Failed to perform action {action_name}. HTTP Status Code: {response.status_code}"}

@app.route('/api/modifycomputeresources', methods=['POST'])
def modify_compute_resources():
    """
    API endpoint to modify compute resources by triggering actions like podCpu, podMemory, or deploymentCpu.
    
    The action_name and action_params should be provided in the JSON body of the POST request.
    
    Example JSON Body:
    {
        "action_name": "podCpu",
        "action_params": {
            "name": "nginx",
            "namespace": "default",
            "updateCpuRequest": "300M"
        }
    }
    
    Returns:
        JSON response from the Robusta API.
    """
    data = request.get_json()
    action_name = data.get("action_name")
    action_params = data.get("action_params")

    if not action_name or not action_params:
        return jsonify({"error": "Invalid input, action_name and action_params are required"}), 400

    result = handle_action(action_name, action_params)
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
