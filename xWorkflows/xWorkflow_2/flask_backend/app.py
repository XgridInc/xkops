from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)

# MongoDB connection string (replace with your connection string)
#mongo_uri = "mongodb://localhost:27017/"

# Connect to MongoDB
client = MongoClient("mongodb://admin:password@mongo-db-0.mongo-db.default.svc.cluster.local:27017")

# Accessing the database
db = client['k8sData']

# Accessing the collection
collection = db['nodes']

# API endpoint to fetch nodes data
@app.route('/nodes', methods=['GET'])
def get_nodes():
    # Fetching all documents from the collection
#    cursor = collection.find()

    # Converting documents to list
 #   nodes_list = list(cursor)
    nodes = list(collection.find({}, {'_id': 0}))
    # Closing the connection
    client.close()
    return jsonify(nodes)

    # Returning JSON response
#    return jsonify(nodes_list)

@app.route('/')
def home():
    return "Welcome to the Flask API!"


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')

