#!/bin/bash

# Deploy using pre-built Docker image
# Usage: ./deploy-image.sh [image-name] [environment]

IMAGE_NAME=${1:-"yourusername/docs-app:latest"}
ENVIRONMENT=${2:-"production"}

echo "🚀 Deploying $IMAGE_NAME..."

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# Docker Image Configuration
DOCKER_IMAGE=$IMAGE_NAME

# Database Configuration
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32 2>/dev/null || echo "change-this-root-password")
MYSQL_PASSWORD=$(openssl rand -base64 24 2>/dev/null || echo "change-this-password")

# Application Configuration
NEXTAUTH_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "change-this-secret-key")
NEXTAUTH_URL=http://localhost:3002

# Port Configuration
APP_PORT=3002
STUDIO_PORT=5556
EOF
    echo "✅ Created .env file with secure defaults"
fi

# Pull the latest image
echo "📥 Pulling Docker image..."
docker pull "$IMAGE_NAME"

# Deploy with docker-compose
echo "🐳 Starting services..."
docker-compose -f docker-compose.image.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 15

# Check status
echo "📊 Service Status:"
docker-compose -f docker-compose.image.yml ps

# Get the actual ports from environment
APP_PORT=$(grep APP_PORT .env | cut -d'=' -f2 || echo "3002")
STUDIO_PORT=$(grep STUDIO_PORT .env | cut -d'=' -f2 || echo "5556")

echo ""
echo "✅ Deployment Complete!"
echo "🌐 Next.js App: http://localhost:$APP_PORT"
echo "🔍 Prisma Studio: http://localhost:$STUDIO_PORT"
echo "🗄️  MySQL: localhost:3307"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose -f docker-compose.image.yml logs -f app"
echo "   Stop: docker-compose -f docker-compose.image.yml down"
echo "   Restart: docker-compose -f docker-compose.image.yml restart" 