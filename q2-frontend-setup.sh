#!/bin/bash
# q2-frontend-setup.sh
# Run this script on the FRONTEND EC2 Instance

# Ensure the user provides the Backend IP
if [ -z "$1" ]; then
    echo "❌ Error: Please provide the public/private IP of your Backend EC2 instance."
    echo "Usage: ./q2-frontend-setup.sh <BACKEND_IP>"
    exit 1
fi

BACKEND_IP=$1

echo "====================================="
echo "🚀 Setting up Frontend EC2 Instance..."
echo "🔗 Connected to Backend IP: $BACKEND_IP"
echo "====================================="

# 1. Update and install Docker
echo "📦 Installing Docker..."
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

# 2. Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# 3. Create a directory for the frontend, or assume we are in it
mkdir -p ~/app/frontend
cd ~/app/frontend

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "⚠️ Warning: Frontend files not found in ~/app/frontend."
    echo "Please copy your frontend codebase (Dockerfile, server.js, package.json, public/, views/) here."
    echo "Then run:"
    echo "  export FLASK_URL=http://$BACKEND_IP:5000"
    echo "  docker build -t express-frontend ."
    echo "  docker run -d -p 80:3000 -e FLASK_URL=\$FLASK_URL --name frontend-container --restart unless-stopped express-frontend"
    exit 0
fi

echo "🔨 Building Express Frontend Docker Image..."
sudo docker build -t express-frontend .

echo "🏃 Running Frontend Container on Port 80..."
# Stop existing container if it exists
sudo docker stop frontend-container 2>/dev/null
sudo docker rm frontend-container 2>/dev/null

# Run new container
# Note: we map port 80 on the EC2 host to port 3000 in the container
sudo docker run -d -p 3001:3000 -e FLASK_URL="http://$BACKEND_IP:5000" --name frontend-container-q2 --restart unless-stopped express-frontend

echo "✅ Frontend setup complete!"
echo "====================================="
echo "Frontend is running on Port 3001 (HTTP)."
echo "You can now access the app via your browser at:"
echo "http://<FRONTEND_PUBLIC_IP>:3001/"
echo "Make sure your AWS Security Group allows Port 3001 inbound traffic."
echo "====================================="
