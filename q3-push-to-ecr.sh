#!/bin/bash
# q3-push-to-ecr.sh
# Run this on your local machine with AWS CLI configured

AWS_REGION="us-east-1"
ACCOUNT_ID="<YOUR_ACCOUNT_ID>"

echo "====================================="
echo "☁️ Pushing Docker Images to AWS ECR..."
echo "====================================="

# Ensure AWS CLI is installed and configured
if ! command -v aws &> /dev/null
then
    echo "❌ AWS CLI could not be found. Please install it first."
    exit 1
fi

echo "🔑 Logging into AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "🔨 Building Backend Image..."
docker build -t docker-assignment-backend ./backend

echo "🔨 Building Frontend Image..."
docker build -t docker-assignment-frontend ./frontend

echo "🏷️ Tagging Images for ECR..."
docker tag docker-assignment-backend:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/docker-assignment-backend:latest
docker tag docker-assignment-frontend:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/docker-assignment-frontend:latest

echo "⬆️ Pushing Backend Image..."
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/docker-assignment-backend:latest

echo "⬆️ Pushing Frontend Image..."
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/docker-assignment-frontend:latest

echo "✅ SUCCESS! Images pushed to ECR."
echo "You can now configure your ECS Task Definitions."
