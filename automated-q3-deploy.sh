#!/bin/bash
# automated-q3-deploy.sh - Run this on the EC2 instance to deploy to ECR and ECS

REGION="eu-west-1"

echo "========================================"
echo "🚀 Starting Automated AWS Q3 Deployment!"
echo "========================================"

export AWS_DEFAULT_REGION=$REGION
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🔑 Detected Account ID: $ACCOUNT_ID"

echo "1️⃣ Creating ECR Repositories..."
aws ecr create-repository --repository-name docker-assignment-backend --region $REGION || true
aws ecr create-repository --repository-name docker-assignment-frontend --region $REGION || true

echo "2️⃣ Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

echo "3️⃣ Building & Pushing Backend Image..."
cd ~/docker-assignment/backend
docker build -t docker-assignment-backend .
docker tag docker-assignment-backend:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-backend:latest
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-backend:latest

echo "4️⃣ Building & Pushing Frontend Image..."
cd ~/docker-assignment/frontend
docker build -t docker-assignment-frontend .
docker tag docker-assignment-frontend:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-frontend:latest
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-frontend:latest

echo "5️⃣ Creating ECS Cluster..."
aws ecs create-cluster --cluster-name docker-assignment-cluster

echo "6️⃣ Registering ECS Task Definitions..."

# Prepare backend JSON
cat <<EOF > backend-task.json
{
    "family": "flask-backend-task",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "flask-backend-container",
            "image": "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-backend:latest",
            "essential": true,
            "portMappings": [{"containerPort": 5000, "hostPort": 5000}]
        }
    ]
}
EOF

# Prepare frontend JSON
cat <<EOF > frontend-task.json
{
    "family": "express-frontend-task",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "express-frontend-container",
            "image": "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/docker-assignment-frontend:latest",
            "essential": true,
            "portMappings": [{"containerPort": 3000, "hostPort": 3000}],
            "environment": [{"name": "FLASK_URL", "value": "http://placeholder:5000"}]
        }
    ]
}
EOF

# Note: ecsTaskExecutionRole MUST exist. We assume it does (AWS creates it automatically usually, if not it will fail).
aws ecs register-task-definition --cli-input-json file://backend-task.json
aws ecs register-task-definition --cli-input-json file://frontend-task.json

echo "✅ Deployment Scripts Executed Successfully!"
echo "Your images are now entirely on AWS ECR, and your ECS cluster 'docker-assignment-cluster' is created."
echo "You can view them in your ECS Console!"
