# Dockerfile Contract

# Use an official Node runtime as a parent image
FROM node:latest

# Set the working directory
WORKDIR /usr/app

# Copy package.json and package-lock.json to the container
COPY package*.json .

# Install dependencies
RUN apt-get update & npm install --quiet

# Copy the app source code to the container
COPY . .

# Expose port
EXPOSE 3000

# Set the command to start the app
CMD ["npm", "start"]
