package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Kubecost API endpoint URL, declared variable to hold the URL
var kubecostAPIURL string

// Creating loggers to use in logs
var (
	flags       = log.Ldate | log.Ltime | log.Lshortfile
	infoLogger  = log.New(os.Stdout, "INFO: ", flags)
	errorLogger = log.New(os.Stdout, "ERROR: ", flags)
)

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
		errorLogger.Println("Error making GET request to Kubecost API: %w", err)
		return nil, err
	}
	defer response.Body.Close()

	// Read response data
	body, err := io.ReadAll(response.Body)
	if err != nil {
		errorLogger.Println("Error reading response body: %w", err)
		return nil, err
	}

	// Parse JSON response
	var data map[string]interface{}
	err = json.Unmarshal(body, &data)
	if err != nil {
		errorLogger.Println("Error unmarshalling JSON response: %w", err)
		return nil, err
	}

	// Ensure that 'items' key exists and is of the correct type
	items, ok := data["items"].([]interface{})
	if !ok {
		errorLogger.Println("Error: 'items' field is not a slice of interfaces")
		return nil, err
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
		errorLogger.Println("Error creating index: %w", err)
		return nil
	}

	// Insert volumes into MongoDB
	for _, volume := range volumes {
		_, err := collection.InsertOne(context.Background(), volume)
		if err != nil {
			if mongo.IsDuplicateKeyError(err) {
				errorLogger.Println("Document with name '" + volume.Name + "' already exists.")
				// Handle duplicate entry gracefully
				continue
			}
			errorLogger.Println("Error inserting document into MongoDB: %w", err)
			return nil
		}
	}
	return nil
}

func main() {
	// Retrieve environment variables
	kubecostAPIURL := os.Getenv("KUBECOST_API_URL")
	mongoURI := os.Getenv("MONGO_URI")
	dbName := os.Getenv("DB_NAME")
	collectionName := os.Getenv("COLLECTION_NAME")

	if kubecostAPIURL == "" || mongoURI == "" || dbName == "" || collectionName == "" {
		errorLogger.Println("Missing required environment variables.")
		return
	}

	// Connect to MongoDB
	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		errorLogger.Println("Error connecting to MongoDB:", err)
		return
	}
	defer client.Disconnect(context.Background())

	// Get a handle to the database and collection
	db := client.Database(dbName)
	collection := db.Collection(collectionName)

	// Get unclaimed volumes
	unclaimedPVs, err := GetUnclaimedVolumes()
	if err != nil {
		errorLogger.Println("Error retrieving unclaimed volumes:", err)
		return
	}

	// Print a success message for data retrieval
	infoLogger.Println("Successfully retrieved data from Kubecost API!")

	// Process or print the list of unclaimed volumes
	if len(unclaimedPVs) > 0 {
		infoLogger.Println("Unclaimed Persistent Volumes:")
		for _, pv := range unclaimedPVs {
			fmt.Println("-", pv.Name)
		}

		// Save unclaimed volumes to MongoDB
		err = SaveVolumesToMongoDB(collection, unclaimedPVs)
		if err != nil {
			errorLogger.Println("Error saving volumes to MongoDB:", err)
			return
		}

		infoLogger.Println("Unclaimed volumes saved to MongoDB successfully!")
	} else {
		infoLogger.Println("No unclaimed Persistent Volumes found.")
	}
}
