# Use an official Node.js runtime as a parent image
FROM node:latest
# Set the working directory in the container
WORKDIR /app
# Define an argument for the React app's Nginx URL
ARG REACT_APP_BACKEND_URL
# Set an environment variable for the React app's Nginx URL
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
# Copy package.json and package-lock.json to the working directory
COPY package*.json ./
# Install Node.js dependencies
RUN npm install
# Copy the 'public' directory to the container (for static assets)
COPY public/ ./public/
COPY src/ ./src/
# Expose the port your app will run on (adjust if necessary)
EXPOSE 3000
# Start your React app (replace 'start' with the appropriate script)
CMD ["npm", "start"]
