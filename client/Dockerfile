# Dockerfile Contract

# Use an official Node runtime as a parent image
FROM node:latest

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the app source code to the container
COPY . .

# Build the app
RUN npm run build

# Set the command to start the app
CMD ["npm", "start"]

