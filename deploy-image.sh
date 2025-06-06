#!/bin/bash

# Deploy using pre-built Docker image
# Usage: ./deploy-image.sh [image-name] [ip-address]

IMAGE_NAME=${1:-"docs-app/docs-app:latest"}
CUSTOM_IP=${2}

echo "🚀 Deploying $IMAGE_NAME..."

# Check for tar files in docker-images folder and load them
if [ -d "docker-images" ]; then
    echo "📦 Checking for Docker image tar files..."
    TAR_FILES=$(find docker-images -name "*.tar" -type f 2>/dev/null)
    
    if [ -n "$TAR_FILES" ]; then
        echo "🔍 Found tar files in docker-images folder:"
        echo "$TAR_FILES" | while read -r tar_file; do
            echo "  - $tar_file"
        done
        
        echo "📥 Loading Docker images from tar files..."
        echo "$TAR_FILES" | while read -r tar_file; do
            if [ -f "$tar_file" ]; then
                echo "Loading: $tar_file"
                docker load -i "$tar_file"
                if [ $? -eq 0 ]; then
                    echo "✅ Successfully loaded: $tar_file"
                else
                    echo "❌ Failed to load: $tar_file"
                fi
            fi
        done
        
        # Verify that the specified image exists after loading
        echo "🔍 Verifying image $IMAGE_NAME exists..."
        if docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
            echo "✅ Image $IMAGE_NAME verified and ready for deployment"
        else
            echo "❌ Error: Image $IMAGE_NAME not found after loading tar files"
            echo "💡 Available images:"
            docker images --format "table {{.Repository}}:{{.Tag}}\t{{.CreatedAt}}" | head -10
            echo ""
            echo "Please check:"
            echo "  1. The tar file contains the correct image"
            echo "  2. The image name matches exactly (including tag)"
            echo "  3. Use: docker load -i your-file.tar && docker images to verify"
            exit 1
        fi
    else
        echo "📭 No tar files found in docker-images folder"
    fi
else
    echo "📁 docker-images folder not found, skipping tar file check"
fi

# Determine deployment target and get appropriate IP
if [ -n "$CUSTOM_IP" ]; then
    # Custom IP provided
    PUBLIC_IP="$CUSTOM_IP"
    echo "📍 Using provided IP: $PUBLIC_IP"
elif curl -s --connect-timeout 5 http://169.254.169.254/latest/meta-data/public-ipv4 > /dev/null 2>&1; then
    # Running on EC2, get public IP
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo "📍 Auto-detected EC2 Public IP: $PUBLIC_IP"
else
    # Local deployment
    PUBLIC_IP="localhost"
    echo "📍 Local deployment: $PUBLIC_IP"
fi

# Validate IP format if not localhost
if [[ "$PUBLIC_IP" != "localhost" && ! $PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "❌ Error: Invalid IP address format: $PUBLIC_IP"
    echo "Usage: ./deploy-image.sh [image-name] [ip-address]"
    echo "Example: ./deploy-image.sh myapp:latest 54.123.45.67"
    exit 1
fi

# Create or update environment file
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
NEXTAUTH_URL=http://$PUBLIC_IP:3002

# Port Configuration
APP_PORT=3002
STUDIO_PORT=5556
EOF
    echo "✅ Created .env file with secure defaults"
else
    echo "📝 Updating .env file (preserving existing credentials)..."
    
    # Update Docker image - using # as delimiter to handle image names with forward slashes
    # This is a workaround for a known issue with sed on Windows
    if grep -q "DOCKER_IMAGE=" .env; then
        sed -i.bak "s#DOCKER_IMAGE=.*#DOCKER_IMAGE=$IMAGE_NAME#" .env
    else
        echo "DOCKER_IMAGE=$IMAGE_NAME" >> .env
    fi
    
    # Update NEXTAUTH_URL with current IP
    if grep -q "NEXTAUTH_URL=" .env; then
        sed -i.bak "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=http://$PUBLIC_IP:3002|" .env
        echo "🔗 Updated NEXTAUTH_URL to: http://$PUBLIC_IP:3002"
    else
        echo "NEXTAUTH_URL=http://$PUBLIC_IP:3002" >> .env
    fi
    
    # Only add missing database credentials
    if ! grep -q "MYSQL_ROOT_PASSWORD=" .env; then
        echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32 2>/dev/null || echo "change-this-root-password")" >> .env
        echo "🔐 Generated new MySQL root password"
    fi
    
    if ! grep -q "MYSQL_PASSWORD=" .env; then
        echo "MYSQL_PASSWORD=$(openssl rand -base64 24 2>/dev/null || echo "change-this-password")" >> .env
        echo "🔐 Generated new MySQL user password"
    fi
    
    # Only add missing application credentials
    if ! grep -q "NEXTAUTH_SECRET=" .env; then
        echo "NEXTAUTH_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "change-this-secret-key")" >> .env
        echo "🔐 Generated new NextAuth secret"
    fi
    
    # Only add missing port configuration
    if ! grep -q "APP_PORT=" .env; then
        echo "APP_PORT=3002" >> .env
    fi
    
    if ! grep -q "STUDIO_PORT=" .env; then
        echo "STUDIO_PORT=5556" >> .env
    fi
    
    echo "✅ Updated .env file (existing credentials preserved)"
fi

# Pull the latest image (only if not already available locally)
echo "🔍 Checking if image exists locally..."
if docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "✅ Image $IMAGE_NAME found locally, skipping pull"
else
    echo "📥 Image not found locally, pulling from registry..."
    if docker pull "$IMAGE_NAME"; then
        echo "✅ Successfully pulled $IMAGE_NAME"
    else
        echo "❌ Failed to pull $IMAGE_NAME from registry"
        echo "💡 Make sure the image exists locally or is available in a registry"
        exit 1
    fi
fi

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
echo "🌐 Next.js App: http://$PUBLIC_IP:$APP_PORT"
echo "🔍 Prisma Studio: http://$PUBLIC_IP:$STUDIO_PORT"
if [ "$PUBLIC_IP" != "localhost" ]; then
    echo "🗄️  MySQL: $PUBLIC_IP:3307"
else
    echo "🗄️  MySQL: localhost:3307"
fi
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose -f docker-compose.image.yml logs -f app"
echo "   Stop: docker-compose -f docker-compose.image.yml down"
echo "   Restart: docker-compose -f docker-compose.image.yml restart" 