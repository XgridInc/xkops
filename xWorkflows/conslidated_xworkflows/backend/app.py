from flask import Flask, jsonify, request
from flask_cors import CORS
from pymongo import MongoClient
import os
import requests

app = Flask(__name__)
CORS(app)  # This will allow all domains

ROBUSTA_URL = "http://localhost:8080/api/trigger"
# Fetch Robusta URL from environment variables
#ROBUSTA_URL = os.getenv("ROBUSTA_URL")

# Ensure the ROBUSTA_URL is provided
if not ROBUSTA_URL:
    raise ValueError("ROBUSTA_URL environment variable is not set")

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

@app.route('/abandoned_workloads', methods=['GET'])
def get_abandoned_workloads():
    """
    Retrieves all documents from the 'collection_abandoned_workloads' collection in MongoDB.

    Returns:
        flask.Response: JSON response containing abandoned workloads data, or an error message if the collection is not accessible.
    """    
    collection = connect_to_mongodb('collection_abandoned_workloads')
    if collection is not None:
        abandoned_workloads = list(collection.find({}, {'_id': 0}))  # Omit the '_id' field from the response
        return jsonify(abandoned_workloads)
    else:
        return jsonify({"error": "Could not connect to the abandoned workloads collection"}), 500

## DELETE COLLECTION ENTRIES APIS
@app.route('/delete_unclaimed_volume', methods=['DELETE'])
def delete_unclaimed_volume_entry():
    try:
        volume_name = request.args.get('volume')
        
        if not volume_name:
            return jsonify({"error": "Please provide a valid volume name"}), 400

        collection = connect_to_mongodb('collection_volume')

        result = collection.delete_many({"name": volume_name})
        
        if result.deleted_count > 0:
            return jsonify({"message": f"Successfully deleted {result.deleted_count} entries with volume '{volume_name}'"}), 200
        else:
            return jsonify({"message": "No entries found with the given volume"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

###
@app.route('/delete_abandoned_workloads', methods=['DELETE'])
def delete_abandoned_workloads_entry():
    try:
        pod_name = request.args.get('pod')

        if not pod_name:
            return jsonify({"error": "Please provide a valid pod name"}), 400

        collection = connect_to_mongodb('collection_abandoned_workloads')

        result = collection.delete_many({"pod": pod_name})

        if result.deleted_count > 0:
            return jsonify({"message": f"Successfully deleted {result.deleted_count} entries with pod '{pod_name}'"}), 200
        else:
            return jsonify({"message": "No entries found with the given pod"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500


## ROBUSTA ACTIONS
## 1. UNCLAIM VOLUME
# kubectl port-forward svc/robusta-runner 8080:80

@app.route("/delete_pv", methods=["POST"])
def delete_pv():
    """
    Deletes a Persistent Volume (PV) by making a request to the Robusta API.
    If successful, deletes corresponding entries from MongoDB.
    Expects a JSON payload with the 'pv_name'.
    """
    mongo_message = "No MongoDB operation attempted"  # Default message if MongoDB is not accessed

    try:
        data = request.get_json()

        # Validate input data
        pv_name = data.get("pv_name")
        if not pv_name:
            return jsonify({"error": "PV name is required", "mongo_message": mongo_message}), 400

        # Prepare payload and headers for the Robusta API
        payload = {
            "action_name": "delete_persistent_volume",
            "action_params": {"name": pv_name},
        }
        headers = {"Content-Type": "application/json"}
        
        # Make the request to Robusta API and raise an exception for non-2xx status codes
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API response is successful, proceed to delete from MongoDB
        if response.status_code == 200:
            try:
                collection = connect_to_mongodb('collection_volume')
                result = collection.delete_many({"name": pv_name})

                if result.deleted_count > 0:
                    mongo_message = f"Successfully deleted {result.deleted_count} entries with volume '{pv_name}'"
                else:
                    mongo_message = "No entries found with the given volume"

            except Exception as e:
                mongo_message = f"Error while deleting from MongoDB: {str(e)}"
                app.logger.error(f"MongoDB deletion error: {e}")

        # Return success message with Robusta API response and MongoDB status
        return jsonify({
            "message": f"PV {pv_name} deletion initiated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202
    
    except requests.exceptions.HTTPError as http_err:
        # Handle HTTP errors from Robusta API
        app.logger.error(f"HTTP error occurred: {http_err}")
        return jsonify({
            "error": "Error from Robusta API",
            "details": str(http_err),
            "mongo_message": mongo_message
        }), response.status_code if response else 500
    
    except requests.exceptions.RequestException as req_err:
        # Handle general request exceptions (network errors, timeouts, etc.)
        app.logger.error(f"Request exception occurred: {req_err}")
        return jsonify({
            "error": "Error while connecting to Robusta API",
            "details": str(req_err),
            "mongo_message": mongo_message
        }), 500

    except Exception as e:
        # Catch any other unexpected exceptions
        app.logger.error(f"Unexpected error: {e}")
        return jsonify({
            "error": "Internal server error",
            "details": str(e),
            "mongo_message": mongo_message
        }), 500


### 2. ABONDONED WORKFLOW ROBUSTA ACTION CALLING


@app.route("/delete_deployment", methods=["POST"])
def delete_deployment():
    """
    Deletes a deployment by making a request to the Robusta API.
    Expects a JSON payload with the 'name' and 'namespace'.
    """
    try:
        data = request.get_json()
        deployment_name = data.get("name")
        namespace = data.get("namespace")

        if not deployment_name or not namespace:
            return jsonify({"error": "Deployment name and namespace are required"}), 400

        # Prepare payload for the Robusta API
        payload = {
            "action_name": "deleteDeployment",
            "action_params": {"name": deployment_name, "namespace": namespace},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        return jsonify({
            "message": f"Deployment {deployment_name} deletion initiated",
            "status_code": response.status_code,
            "response": response.json()
        }), 202

    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500



@app.route("/delete_pod", methods=["POST"])
def delete_pod():
    """
    Deletes a pod by making a request to the Robusta API.
    If successful, deletes the pod entry from MongoDB.
    Expects a JSON payload with the 'name' and 'namespace'.
    """
    mongo_message = "No MongoDB operation attempted"  # Default message if MongoDB is not accessed

    try:
        data = request.get_json()
        pod_name = data.get("name")
        namespace = data.get("namespace")

        if not pod_name or not namespace:
            return jsonify({"error": "Pod name and namespace are required", "mongo_message": mongo_message}), 400

        # Prepare payload for the Robusta API
        payload = {
            "action_name": "deletePod",
            "action_params": {"name": pod_name, "namespace": namespace},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API response is successful, proceed to delete from MongoDB
        if response.status_code == 200:
            try:
                collection = connect_to_mongodb('collection_abandoned_workloads')
                result = collection.delete_many({"name": pod_name, "namespace": namespace})

                if result.deleted_count > 0:
                    mongo_message = f"Successfully deleted {result.deleted_count} entries with pod '{pod_name}' in namespace '{namespace}'"
                else:
                    mongo_message = "No entries found with the given pod name and namespace"

            except Exception as e:
                mongo_message = f"Error while deleting from MongoDB: {str(e)}"
                app.logger.error(f"MongoDB deletion error: {e}")

        # Return success message with Robusta API response and MongoDB status
        return jsonify({
            "message": f"Pod {pod_name} deletion initiated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202

    except requests.exceptions.RequestException as e:
        # Handle request exceptions (network errors, timeouts, etc.)
        return jsonify({
            "error": str(e),
            "mongo_message": mongo_message
        }), 500

#curl -X POST http://localhost:5000/delete_deployment -H 'Content-Type: application/json' -d '{"name": "nginx-deployment", "namespace": "default"}'

#curl -X POST http://localhost:5000/delete_pod -H 'Content-Type: application/json' -d '{"name": "temp-pod", "namespace": "default"}'

## 4. Workflow: Container resizing
@app.route("/update_pod_cpu", methods=["POST"])
def update_pod_cpu():
    """
    Updates the CPU request for a specific pod using the Robusta API.
    If successful, modifies the recommendedRequest.cpu value to None in the MongoDB collection.
    """
    try:
        data = request.get_json()
        pod_name = data.get("name")
        namespace = data.get("namespace")
        cpu_request = data.get("updateCpuRequest")

        if not pod_name or not namespace or not cpu_request:
            return jsonify({"error": "Pod name, namespace, and CPU request are required"}), 400

        # Prepare the payload for the Robusta API
        payload = {
            "action_name": "podCpu",
            "action_params": {"name": pod_name, "namespace": namespace, "updateCpuRequest": cpu_request},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to the Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API request is successful, update MongoDB
        collection = connect_to_mongodb('collection_sizingv2')
        query = {"controllerName": pod_name, "controllerKind": "pod", "namespace": namespace}
        update = {"$set": {"recommendedRequest.cpu": None}}

        result = collection.update_one(query, update)

        mongo_message = ""
        if result.matched_count > 0:
            if result.modified_count > 0:
                mongo_message = "Successfully modified 'recommendedRequest.cpu' in MongoDB."
            else:
                mongo_message = "Document found, but no modification was made (it might already be set to None)."
        else:
            mongo_message = "No document found with the given criteria in MongoDB."

        return jsonify({
            "message": f"CPU request for Pod {pod_name} updated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202

    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

    except Exception as e:
        return jsonify({"error": "Internal server error", "details": str(e)}), 500


@app.route("/update_deployment_cpu", methods=["POST"])
def update_deployment_cpu():
    """
    Updates the CPU request for a specific deployment using the Robusta API.
    If successful, modifies the recommendedRequest.cpu value to None in the MongoDB collection.
    Expects a JSON payload with the 'name', 'namespace', and 'updateCpuRequest'.
    """
    try:
        data = request.get_json()
        deployment_name = data.get("name")
        namespace = data.get("namespace")
        cpu_request = data.get("updateCpuRequest")

        if not deployment_name or not namespace or not cpu_request:
            return jsonify({"error": "Deployment name, namespace, and CPU request are required"}), 400

        # Prepare the payload for the Robusta API
        payload = {
            "action_name": "deploymentCpu",
            "action_params": {"name": deployment_name, "namespace": namespace, "updateCpuRequest": cpu_request},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to the Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API request is successful, update MongoDB
        collection = connect_to_mongodb('collection_sizingv2')
        query = {"controllerName": deployment_name, "controllerKind": "deployment", "namespace": namespace}
        update = {"$set": {"recommendedRequest.cpu": None}}

        result = collection.update_one(query, update)

        mongo_message = ""
        if result.matched_count > 0:
            if result.modified_count > 0:
                mongo_message = "Successfully modified 'recommendedRequest.cpu' in MongoDB."
            else:
                mongo_message = "Document found, but no modification was made (it might already be set to None)."
        else:
            mongo_message = "No document found with the given criteria in MongoDB."

        return jsonify({
            "message": f"CPU request for Deployment {deployment_name} updated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202

    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

    except Exception as e:
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

@app.route("/update_deployment_memory", methods=["POST"])
def update_deployment_memory():
    """
    Updates the memory request for a specific deployment using the Robusta API.
    If successful, modifies the recommendedRequest.memory value to None in the MongoDB collection.
    Expects a JSON payload with the 'name', 'namespace', and 'updateMemoryRequest'.
    """
    try:
        data = request.get_json()
        deployment_name = data.get("name")
        namespace = data.get("namespace")
        memory_request = data.get("updateMemoryRequest")

        if not deployment_name or not namespace or not memory_request:
            return jsonify({"error": "Deployment name, namespace, and memory request are required"}), 400

        # Prepare the payload for the Robusta API
        payload = {
            "action_name": "deploymentMemory",
            "action_params": {"name": deployment_name, "namespace": namespace, "updateMemoryRequest": memory_request},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to the Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API request is successful, update MongoDB
        collection = connect_to_mongodb('collection_sizingv2')
        query = {"controllerName": deployment_name, "controllerKind": "deployment", "namespace": namespace}
        update = {"$set": {"recommendedRequest.memory": None}}

        result = collection.update_one(query, update)

        mongo_message = ""
        if result.matched_count > 0:
            if result.modified_count > 0:
                mongo_message = "Successfully modified 'recommendedRequest.memory' in MongoDB."
            else:
                mongo_message = "Document found, but no modification was made (it might already be set to None)."
        else:
            mongo_message = "No document found with the given criteria in MongoDB."

        return jsonify({
            "message": f"Memory request for Deployment {deployment_name} updated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202

    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

    except Exception as e:
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

@app.route("/update_pod_memory", methods=["POST"])
def update_pod_memory():
    """
    Updates the memory request for a specific pod using the Robusta API.
    If successful, modifies the recommendedRequest.memory value to None in the MongoDB collection.
    Expects a JSON payload with the 'name', 'namespace', and 'updateMemoryRequest'.
    """
    try:
        data = request.get_json()
        pod_name = data.get("name")
        namespace = data.get("namespace")
        memory_request = data.get("updateMemoryRequest")

        # Validate input data
        if not pod_name or not namespace or not memory_request:
            return jsonify({"error": "Pod name, namespace, and memory request are required"}), 400

        # Prepare payload for the Robusta API
        payload = {
            "action_name": "podMemory",
            "action_params": {"name": pod_name, "namespace": namespace, "updateMemoryRequest": memory_request},
        }
        headers = {"Content-Type": "application/json"}

        # Make the request to Robusta API
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()

        # If Robusta API request is successful, update MongoDB
        collection = connect_to_mongodb('collection_sizingv2')
        query = {"controllerName": pod_name, "controllerKind": "pod", "namespace": namespace}
        update = {"$set": {"recommendedRequest.memory": None}}

        result = collection.update_one(query, update)

        mongo_message = ""
        if result.matched_count > 0:
            if result.modified_count > 0:
                mongo_message = "Successfully modified 'recommendedRequest.memory' in MongoDB."
            else:
                mongo_message = "Document found, but no modification was made (it might already be set to None)."
        else:
            mongo_message = "No document found with the given criteria in MongoDB."

        # Return success message along with the Robusta API response details and MongoDB status
        return jsonify({
            "message": f"Memory request for Pod {pod_name} updated",
            "status_code": response.status_code,
            "response": response.json(),
            "mongo_message": mongo_message
        }), 202

    except requests.exceptions.RequestException as e:
        # Handle request exceptions
        return jsonify({"error": str(e)}), 500

    except Exception as e:
        # Handle any other exceptions
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

# Update Pod CPU
# curl -X POST http://localhost:5000/update_pod_cpu -H 'Content-Type: application/json' -d '{"name": "nginx", "namespace": "default", "updateCpuRequest": "300m"}'

# Update Deployment CPU
# curl -X POST http://localhost:5000/update_deployment_cpu -H 'Content-Type: application/json' -d '{"name": "nginx-deployment", "namespace": "default", "updateCpuRequest": "300m"}'

# Update Deployment Memory
# curl -X POST http://localhost:5000/update_deployment_memory -H 'Content-Type: application/json' -d '{"name": "nginx-deployment", "namespace": "default", "updateMemoryRequest": "30M"}'

# Update Pod Memory
# curl -X POST http://localhost:5000/update_pod_memory -H 'Content-Type: application/json' -d '{"name": "nginx", "namespace": "default", "updateMemoryRequest": "300M"}'


@app.route('/get_savings', methods=['GET'])
def get_savings():
    # API endpoint for model savings API
    url = 'http://localhost:9090/model/savings'
    
    # Query parameters to pass
    params = {
        'req': '7320'  # You can modify this based on what you need
    }

    # Forward the request to the specified URL
    response = requests.get(url, params=params)
    
    # Check if the response was successful
    if response.status_code == 200:
        # Extract the 'development' part of the JSON response
        data = response.json()
        development_data = data.get('development', {})
        
        # Return only the 'development' data
        return jsonify(development_data)
    else:
        # If there was an error, return the error status and message
        return jsonify({
            'error': 'Failed to retrieve data',
            'status_code': response.status_code,
            'message': response.text
        }), response.status_code
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
