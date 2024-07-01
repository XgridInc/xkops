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
    app.run(debug=True, host='0.0.0.0')


'''

from flask import Flask, jsonify, render_template
from pymongo import MongoClient, errors
import os

app = Flask(__name__)

# MongoDB connection details
mongo_host = os.getenv("MONGODB_HOST", "localhost")
mongo_port = os.getenv("MONGODB_PORT", "27017")
mongo_db = os.getenv("MONGODB_DATABASE", "k8sData")
mongo_username = os.getenv("MONGODB_USERNAME", "admin")
mongo_password = os.getenv("MONGODB_PASSWORD", "admin123")

#mongo_uri = "mongodb+srv://umerjamil:go9QLCnSJm4TtmHg@cluster0.e9t1seo.mongodb.net"
mongo_uri = f"mongodb://{mongo_username}:{mongo_password}@{mongo_host}:{mongo_port}/{mongo_db}?authSource=admin"

try:
    print(mongo_uri)
    mongo_client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000,authSource="admin")  # 5-second timeout
#    mongo_client.server_info()  # Force connection on a request as the connect=True parameter of MongoClient seems to be useless here
    db = mongo_client[mongo_db]
    print("Connected to MongoDB successfully!")
except errors.ServerSelectionTimeoutError as err:
    print(f"Failed to connect to MongoDB: {err}")
    db = None  # To handle cases where the DB connection is not established

@app.route('/nodes', methods=['GET'])
def get_nodes():
#    if db is None:
#        return jsonify({"error": "Database connection not established"}), 500

    mongo_client = MongoClient(mongo_uri,authSource="admin")  # 5-second timeout
#    mongo_client.server_info()  # Force connection on a request as the connect=True parameter of MongoClient seems to be useless here
    db = mongo_client[mongo_db]
    nodes_collection = db['nodes']
    nodes = list(nodes_collection.find({}, {'_id': 0}))
    return jsonify(nodes)
#    nodes_collection = db['nodes']
#    nodes = list(nodes_collection.find({}, {'_id': 0}))
    # Debugging: Print the data to the console
#    for node in nodes:
#        print(node)
#    return render_template('nodes.html', nodes=nodes)

@app.route('/')
def home():
    return "Welcome to the Flask API!"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

'''
