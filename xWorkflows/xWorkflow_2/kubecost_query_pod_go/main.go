package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Node represents the structure of each node's information
type Node struct {
	Properties struct {
		Cluster string `json:"cluster"`
		Name    string `json:"name"`
	} `json:"properties"`
	TotalCost float64 `json:"totalCost"`
}

// APIResponse represents the structure of the response from the API
type APIResponse struct {
	Code int               `json:"code"`
	Data []map[string]Node `json:"data"`
}

func main() {
	// Get environment variables
	apiURL := os.Getenv("API_URL")
	if apiURL == "" {
		fmt.Println("Error: API_URL environment variable not set")
		return
	}

	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		fmt.Println("Error: MONGODB_URI environment variable not set")
		return
	}

	mongoDB := os.Getenv("MONGODB_DATABASE")
	if mongoDB == "" {
		fmt.Println("Error: MONGODB_DATABASE environment variable not set")
		return
	}

	mongoUsername := os.Getenv("MONGODB_USERNAME")
	mongoPassword := os.Getenv("MONGODB_PASSWORD")

	// Create MongoDB client options with authentication
	clientOpts := options.Client().ApplyURI(mongoURI)
	if mongoUsername != "" && mongoPassword != "" {
		clientOpts.SetAuth(options.Credential{
			Username: mongoUsername,
			Password: mongoPassword,
		})
	}

	// Create a MongoDB client
	client, err := mongo.NewClient(clientOpts)
	if err != nil {
		fmt.Println("Error creating MongoDB client:", err)
		return
	}

	// Connect to MongoDB
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		fmt.Println("Error connecting to MongoDB:", err)
		return
	}
	defer client.Disconnect(ctx)

	// Get the collection
	collection := client.Database(mongoDB).Collection("nodes")

	// Fetch data from the API
	resp, err := http.Get(apiURL)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		fmt.Println("Error: Received non-200 response code")
		return
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return
	}

	// Print the raw response body
	fmt.Println("Raw response body:", string(body))

	var apiResponse APIResponse
	err = json.Unmarshal(body, &apiResponse)
	if err != nil {
		fmt.Println("Error unmarshalling JSON:", err)
		return
	}

	if apiResponse.Code != 200 {
		fmt.Println("Error: API response code is not 200")
		return
	}

	// Insert data into MongoDB
	for _, nodeMap := range apiResponse.Data {
		for _, node := range nodeMap {
			_, err := collection.InsertOne(ctx, node)
			if err != nil {
				fmt.Println("Error inserting document into MongoDB:", err)
				continue
			}
			fmt.Printf("Inserted: Cluster: %s, Name: %s, TotalCost: %.6f\n", node.Properties.Cluster, node.Properties.Name, node.TotalCost)
		}
	}
}
