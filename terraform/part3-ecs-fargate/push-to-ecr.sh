#!/bin/bash
##############################################################
# push-to-ecr.sh
# Builds Docker images and pushes them to AWS ECR (Part 3)
# Usage: ./push-to-ecr.sh <aws-region> <aws-account-id>
##############################################################
set -e

AWS_REGION=${1:-"us-east-1"}
ACCOUNT_ID=${2:-$(aws sts get-caller-identity --query Account --output text)}
PROJECT="docker-assignment"

FLASK_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT}-flask-backend"
EXPRESS_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT}-express-frontend"

echo "========================================"
echo " ECR Push Script — docker-assignment"
echo " Region : $AWS_REGION"
echo " Account: $ACCOUNT_ID"
echo "========================================"

# Authenticate Docker to ECR
echo ">>> Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin \
    "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Build & push Flask backend
echo ""
echo ">>> Building Flask backend image..."
docker build -t "${PROJECT}-flask-backend:latest" ./backend

echo ">>> Tagging Flask image..."
docker tag "${PROJECT}-flask-backend:latest" "${FLASK_REPO}:latest"

echo ">>> Pushing Flask image to ECR..."
docker push "${FLASK_REPO}:latest"
echo "✅ Flask image pushed: ${FLASK_REPO}:latest"

# Build & push Express frontend
echo ""
echo ">>> Building Express frontend image..."
docker build -t "${PROJECT}-express-frontend:latest" ./frontend

echo ">>> Tagging Express image..."
docker tag "${PROJECT}-express-frontend:latest" "${EXPRESS_REPO}:latest"

echo ">>> Pushing Express image to ECR..."
docker push "${EXPRESS_REPO}:latest"
echo "✅ Express image pushed: ${EXPRESS_REPO}:latest"

echo ""
echo "========================================"
echo " All images pushed successfully!"
echo " Flask ECR  : ${FLASK_REPO}:latest"
echo " Express ECR: ${EXPRESS_REPO}:latest"
echo "========================================"
