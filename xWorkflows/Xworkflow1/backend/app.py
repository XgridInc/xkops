import os
import requests
from pymongo import MongoClient
from flask import Flask, jsonify, request

app = Flask(__name__)

# Environment variables (access these instead of hardcoded values)
mongoURI = os.getenv("MONGO_URI")
dbName = os.getenv("DB_NAME")
collectionName = os.getenv("COLLECTION_NAME")
ROBUSTA_URL = os.getenv("ROBUSTA_URL")

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
    except pymongo.errors.ConnectionFailure:
        return jsonify({"error": "Error connecting to MongoDB"}), 500
    except pymongo.errors.PyMongoError as e:
        return jsonify({"error": f"MongoDB error: {e}"}), 500
    except Exception as e:  # Catch other unexpected errors
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

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)  # Set debug=False for production
