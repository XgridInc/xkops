# # Use an official Node.js runtime as a parent image
# FROM node:16-alpine

# # Set the working directory in the container
# WORKDIR /app

# # Copy package.json and package-lock.json to the working directory
# COPY package*.json ./

# # Install Node.js dependencies and ensure it's using the right file descriptors
# RUN npm install --legacy-peer-deps && npm cache clean --force

# # Copy the rest of the application files
# COPY . .

# # Build the app for production
# RUN npm run build

# # Expose the port your app will run on
# EXPOSE 3000

# # Start your React app
# #CMD ["npm", "start"]
# CMD ["sh", "-c", "ulimit -n 10240 && npm start"]
# # Use an official Node.js runtime as a parent image
# FROM node:latest
# # Set the working directory in the container
# WORKDIR /app
# # Define an argument for the React app's Nginx URL
# # ARG REACT_APP_BACKEND_URL
# # # Set an environment variable for the React app's Nginx URL
# # ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
# # # Copy package.json and package-lock.json to the working directory
# COPY package*.json ./
# # Install Node.js dependencies
# RUN npm install
# # Copy the 'public' directory to the container (for static assets)
# COPY public/ ./public/
# COPY src/ ./src/
# # Expose the port your app will run on (adjust if necessary)
# EXPOSE 3000
# # Start your React app (replace 'start' with the appropriate script)
# CMD ["npm", "start"]

FROM node:16-alpine as build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install Node.js dependencies (include --legacy-peer-deps to handle dependency issues)
RUN npm install --silent --legacy-peer-deps

# Copy the rest of the application files
COPY . .

# Build the app for production
RUN npm run build

# Use Nginx to serve the production build
FROM nginx:alpine

# Copy the build output to Nginx's default directory
COPY --from=build /app/build /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]