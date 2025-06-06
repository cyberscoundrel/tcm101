#!/bin/bash

# Build Docker image from git repository
# Usage: ./build-image.sh [repo-url] [tag]

REPO_URL="https://github.com/cyberscoundrel/tcm101.git"
TAG=${1:-"latest"}
IMAGE_NAME="docs-app/docs-app"
TAR_FILENAME="docs-app-${TAG}.tar"

echo "🚀 Building Docker image from git repository..."
echo "📦 Repository: $REPO_URL"
echo "🏷️  Image: $IMAGE_NAME:$TAG"

# Build the image
docker build -f Dockerfile.remote \
  --build-arg REPO_URL="$REPO_URL" \
  --build-arg BRANCH=main \
  -t "$IMAGE_NAME:$TAG" \
  -t "$IMAGE_NAME:latest" \
  .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📋 Image built: $IMAGE_NAME:$TAG"
    
    # Save image as TAR file
    echo ""
    echo "💾 Saving image as TAR file..."
    docker save -o "$TAR_FILENAME" "$IMAGE_NAME:$TAG"
    
    if [ $? -eq 0 ]; then
        echo "✅ TAR file created: $TAR_FILENAME"
        TAR_SIZE=$(du -h "$TAR_FILENAME" | cut -f1)
        echo "📏 TAR file size: $TAR_SIZE"
        echo ""
        echo "🚀 To transfer to EC2:"
        echo "   scp -i your-key.pem $TAR_FILENAME ec2-user@your-ec2-ip:/home/ec2-user/"
        echo ""
        echo "🐳 On EC2, load the image:"
        echo "   docker load -i $TAR_FILENAME"
        echo "   docker run -d -p 3002:3000 -p 5556:5556 $IMAGE_NAME:$TAG"
    else
        echo "❌ Failed to create TAR file!"
    fi
    
    echo ""
    echo "🚀 Alternative - To push to Docker Hub:"
    echo "   docker push $IMAGE_NAME:$TAG"
    echo "   docker push $IMAGE_NAME:latest"
else
    echo "❌ Build failed!"
    exit 1
fi 