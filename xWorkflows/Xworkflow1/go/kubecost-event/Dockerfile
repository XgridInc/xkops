# Use the official Golang image with Alpine Linux as a base image
FROM golang:1.22.0-alpine

# Set the current working directory inside the container
WORKDIR /app

# Copy go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the main.go file from the kubecost-event folder
COPY ./main.go .

# Build the Go application
RUN go build -o main .

# Command to run the executable
CMD ["./main"]

