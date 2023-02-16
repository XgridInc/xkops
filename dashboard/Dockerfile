# Use the official Node.js 16 image as the base image
FROM node:16

# Set the working directory to /app
WORKDIR /app

#Copy React.js app to /app/client
COPY client ./client

# Set the working directory to /app/client
WORKDIR /app/client

# # Install the dependencies for the React.js app 
# # Build the React.js app
RUN npm install && npm run build

# Set the working directory to /app
WORKDIR /app

#Move the React.js app build to /app
RUN mv ./client/build ./build

# # Remove the React.js app directory
RUN rm -rf ./client

# Copy the package.json and package-lock.json files from the api directory
COPY api/package*.json ./

# Install the dependencies for the Node.js app
RUN npm install

# Copy the Node.js app's code to the image
COPY api .

# Expose port 3000 for the Node.js app
EXPOSE 3000

# Start the Node.js app when the container starts
CMD ["node", "index.js"]
