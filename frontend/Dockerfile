# Use official Node.js LTS alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json .
RUN npm install --production

# Copy application source
COPY . .

# Expose Express port
EXPOSE 3000

# Run the server
CMD ["node", "server.js"]
