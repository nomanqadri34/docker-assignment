#!/bin/bash
# q2-backend-setup.sh
# Run this script on the BACKEND EC2 Instance

echo "====================================="
echo "🚀 Setting up Backend EC2 Instance..."
echo "====================================="

# 1. Update and install Docker
echo "📦 Installing Docker..."
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

# 2. Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# 3. Create a directory for the backend, or assume we are in it
# If the backend files aren't here, we'll write them out
mkdir -p ~/app/backend
cd ~/app/backend

# Check if Dockerfile exists, if not, prompt the user to copy them over
if [ ! -f "Dockerfile" ]; then
    echo "⚠️ Warning: Backend files not found in ~/app/backend."
    echo "Please copy your backend codebase (Dockerfile, app.py, requirements.txt) here."
    echo "Then run:"
    echo "  docker build -t flask-backend ."
    echo "  docker run -d -p 5000:5000 --name backend-container --restart unless-stopped flask-backend"
    exit 0
fi

echo "🔨 Building Flask Backend Docker Image..."
sudo docker build -t flask-backend .

echo "🏃 Running Backend Container..."
# Stop existing container if it exists
sudo docker stop backend-container 2>/dev/null
sudo docker rm backend-container 2>/dev/null

# Run new container
sudo docker run -d -p 5000:5000 --name backend-container --restart unless-stopped flask-backend

echo "✅ Backend setup complete! Testing health endpoint:"
sleep 3
curl http://localhost:5000/health
echo ""
echo "====================================="
echo "Backend is running on Port 5000."
echo "Make sure your AWS Security Group allows Port 5000 inbound traffic."
echo "====================================="
