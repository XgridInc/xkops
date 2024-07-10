from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)

# MongoDB connection string (replace with your connection string)
#mongo_uri = "mongodb://localhost:27017/"

# Connect to MongoDB
client = MongoClient("mongodb://admin:password@mongo-db-0.mongo-db.default.svc.cluster.local:27017")
# Accessing the db
def get_db():
    try:
        db = client['k8sData']
        return db
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error accessing database"}), 500

# Accessing the collection
def get_collection():
    try:
        db = get_db()  # Reuse the database access logic
        collection = db['nodes']
        return collection
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error accessing collection"}), 500


# API endpoint to fetch nodes data
@app.route('/nodes', methods=['GET'])
def get_nodes():
    try:
        collection = get_collection()  # Use the function to access collection
    # Fetching all documents from the collection
#    cursor = collection.find()

    # Converting documents to list
 #   nodes_list = list(cursor)
        nodes = list(collection.find({}, {'_id': 0}))
        return jsonify(nodes)
    except pymongo.errors.PyMongoError:
        return jsonify({"error": "Error fetching nodes"}), 500
    finally:
        # Ensure connection is closed even on errors
        client.close()

# Health check endpoint
@app.route('/health')
def health():
    return jsonify({"status": "OK"}), 200  # Simple JSON response with 200 status code

@app.route('/')
def home():
    return "Welcome to the Flask API!"


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')

