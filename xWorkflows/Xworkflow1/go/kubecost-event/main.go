package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Kubecost API endpoint URL (replace with your actual URL)
const kubecostAPIURL = "http://kubecost-cost-analyzer.kubecost.svc.cluster.local:9003/allPersistentVolumes"

// PersistentVolume represents the structure of a Persistent Volume
type PersistentVolume struct {
	Name   string `json:"name"`
	Status string `json:"status"`
}

// GetUnclaimedVolumes retrieves unclaimed volumes from the Kubecost API
func GetUnclaimedVolumes() ([]PersistentVolume, error) {
	// Make a GET request to the Kubecost API
	response, err := http.Get(kubecostAPIURL)
	if err != nil {
		return nil, fmt.Errorf("error making GET request to Kubecost API: %w", err)
	}
	defer response.Body.Close()

	// Read response data
	body, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response body: %w", err)
	}

	// Parse JSON response
	var data map[string]interface{}
	err = json.Unmarshal(body, &data)
	if err != nil {
		return nil, fmt.Errorf("error unmarshalling JSON response: %w", err)
	}

	// Ensure that 'items' key exists and is of the correct type
	items, ok := data["items"].([]interface{})
	if !ok {
		return nil, fmt.Errorf("error: 'items' field is not a slice of interfaces")
	}

	// Extract volume names and statuses
	var unclaimedPVs []PersistentVolume
	for _, item := range items {
		itemMap, ok := item.(map[string]interface{})
		if !ok {
			continue // Skip if item is not a map
		}

		// Ensure 'status' is a map
		status, ok := itemMap["status"].(map[string]interface{})
		if !ok {
			continue // Skip items without a "status" field or if it's not a map
		}

		// Check if the phase is "Available"
		if phase, ok := status["phase"].(string); ok && phase == "Available" {
			// Ensure 'name' is a string
			if metadata, ok := itemMap["metadata"].(map[string]interface{}); ok {
				if name, ok := metadata["name"].(string); ok {
					pv := PersistentVolume{
						Name:   name,
						Status: "Available",
					}
					unclaimedPVs = append(unclaimedPVs, pv)
				}
			}
		}
	}

	return unclaimedPVs, nil
}

func SaveVolumesToMongoDB(collection *mongo.Collection, volumes []PersistentVolume) error {
	// Create a unique index on the 'name' field
	indexOptions := options.Index().SetUnique(true)
	index := mongo.IndexModel{
		Keys:    map[string]interface{}{"name": 1}, // 1 for ascending, -1 for descending
		Options: indexOptions,
	}

	// Create the index on the collection
	_, err := collection.Indexes().CreateOne(context.Background(), index)
	if err != nil {
		return fmt.Errorf("error creating index: %w", err)
	}

	// Insert volumes into MongoDB
	for _, volume := range volumes {
		_, err := collection.InsertOne(context.Background(), volume)
		if err != nil {
			if mongo.IsDuplicateKeyError(err) {
				fmt.Printf("Document with name '%s' already exists.\n", volume.Name)
				// Handle duplicate entry gracefully
				continue
			}
			return fmt.Errorf("error inserting document into MongoDB: %w", err)
		}
	}
	return nil
}

func main() {
	// MongoDB connection URI
	mongoURI := "mongodb://xworkflow-mongodb-0.xworkflow-mongodb.default.svc.cluster.local:27017,xworkflow-mongodb-1.xworkflow-mongodb.default.svc.cluster.local:27017,xworkflow-mongodb-2.xworkflow-mongodb.default.svc.cluster.local:27017/?replicaSet=xworkflowReplSet"

	// Database and collection names
	dbName := "xworkflow-db"
	collectionName := "xworkflow1-collection"

	// Connect to MongoDB
	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		fmt.Println("Error connecting to MongoDB:", err)
		return
	}
	defer client.Disconnect(context.Background())

	// Get a handle to the database and collection
	db := client.Database(dbName)
	collection := db.Collection(collectionName)

	// Get unclaimed volumes
	unclaimedPVs, err := GetUnclaimedVolumes()
	if err != nil {
		fmt.Println("Error retrieving unclaimed volumes:", err)
		return
	}

	// Print a success message for data retrieval
	fmt.Println("Successfully retrieved data from Kubecost API!")

	// Process or print the list of unclaimed volumes
	if len(unclaimedPVs) > 0 {
		fmt.Println("Unclaimed Persistent Volumes:")
		for _, pv := range unclaimedPVs {
			fmt.Println("-", pv.Name)
		}

		// Save unclaimed volumes to MongoDB
		err = SaveVolumesToMongoDB(collection, unclaimedPVs)
		if err != nil {
			fmt.Println("Error saving volumes to MongoDB:", err)
			return
		}

		fmt.Println("Unclaimed volumes saved to MongoDB successfully!")
	} else {
		fmt.Println("No unclaimed Persistent Volumes found.")
	}
}
