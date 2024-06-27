import requests
from pymongo import MongoClient
from flask import Flask, jsonify, request

app = Flask(__name__)

# MongoDB connection URI and database/collection names
mongoURI = "mongodb://xworkflow-mongodb-0.xworkflow-mongodb.default.svc.cluster.local:27017," \
           "xworkflow-mongodb-1.xworkflow-mongodb.default.svc.cluster.local:27017," \
           "xworkflow-mongodb-2.xworkflow-mongodb.default.svc.cluster.local:27017/?replicaSet=xworkflowReplSet"
dbName = "xworkflow-db"
collectionName = "xworkflow1-collection"

# Robusta API URL for deleting persistent volumes
ROBUSTA_URL = "http://robusta-runner.robusta.svc.cluster.local/api/trigger"

@app.route("/unclaimed_pvs", methods=["GET"])
def get_unclaimed_pvs():
    try:
        with MongoClient(mongoURI) as client:
            db = client[dbName]
            col = db[collectionName]

            filter = {"status": "Available"}  # Filter for unclaimed PVs (assuming "Available" means unclaimed)
            cursor = col.find(filter)
            unclaimed_pvs = [doc["name"] for doc in cursor]  # Extracting "name" field from documents

        return jsonify(unclaimed_pvs)
    except Exception as e:
        print(f"Error fetching unclaimed PVs: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route("/delete_pv", methods=["POST"])
def delete_pv():
    try:
        data = request.get_json()
        pv_name = data.get("pv_name")
        if not pv_name:
            return jsonify({"error": "PV name is required"}), 400

        payload = {
            "action_name": "delete_persistent_volume",
            "action_params": {"name": pv_name},
        }
        headers = {"Content-Type": "application/json"}
        response = requests.post(ROBUSTA_URL, json=payload, headers=headers)
        response.raise_for_status()  # Raise exception for non-2xx status codes

        # Update PV status in MongoDB (optional for informational purposes)
        with MongoClient(mongoURI) as client:
            db = client[dbName]
            col = db[collectionName]
            col.update_one({"name": pv_name}, {"$set": {"status": "deleted"}})  # Update only if necessary

        return jsonify({"message": "PV deletion initiated"})
    except Exception as e:
        print(f"Error deleting PV: {e}")
        return jsonify({"error": "Error deleting PV"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)  # Set debug=False for production
