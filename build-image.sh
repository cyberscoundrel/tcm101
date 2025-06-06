#!/bin/bash

# Build Docker image from git repository
# Usage: ./build-image.sh [repo-url] [docker-username] [tag]

REPO_URL=${1:-"https://github.com/yourusername/centroid-class.git"}
DOCKER_USERNAME=${2:-"yourusername"}
TAG=${3:-"latest"}
IMAGE_NAME="$DOCKER_USERNAME/docs-app"

echo "🚀 Building Docker image from git repository..."
echo "📦 Repository: $REPO_URL"
echo "🏷️  Image: $IMAGE_NAME:$TAG"

# Build the image
docker build \
  --build-arg REPO_URL="$REPO_URL" \
  --build-arg BRANCH=main \
  -t "$IMAGE_NAME:$TAG" \
  -t "$IMAGE_NAME:latest" \
  .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📋 Image built: $IMAGE_NAME:$TAG"
    echo ""
    echo "🚀 To push to Docker Hub:"
    echo "   docker push $IMAGE_NAME:$TAG"
    echo "   docker push $IMAGE_NAME:latest"
    echo ""
    echo "🐳 To run locally:"
    echo "   docker run -d -p 3002:3000 -p 5556:5556 $IMAGE_NAME:$TAG"
    echo ""
    echo "📄 To deploy with docker-compose:"
    echo "   DOCKER_IMAGE=$IMAGE_NAME:$TAG docker-compose -f docker-compose.image.yml up -d"
else
    echo "❌ Build failed!"
    exit 1
fi 