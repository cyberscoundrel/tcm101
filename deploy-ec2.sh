#!/bin/bash

# EC2 Deployment Script for Next.js Docker App
echo "🚀 Starting EC2 deployment..."

# Get EC2 public IP
# Check if IP is provided as argument, otherwise get from metadata
if [ -n "$1" ]; then
    EC2_PUBLIC_IP="$1"
    echo "📍 Using provided EC2 Public IP: $EC2_PUBLIC_IP"
else
    EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo "📍 Auto-detected EC2 Public IP: $EC2_PUBLIC_IP"
fi

# Validate IP format (basic check)
if [[ ! $EC2_PUBLIC_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "❌ Error: Invalid IP address format: $EC2_PUBLIC_IP"
    echo "Usage: ./deploy-ec2.sh [IP_ADDRESS]"
    echo "Example: ./deploy-ec2.sh 54.123.45.67"
    exit 1
fi

# Create environment file
echo "📝 Creating environment configuration..."
cat > .env.local << EOF
# Production Environment Variables
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
MYSQL_PASSWORD=$(openssl rand -base64 24)
NEXTAUTH_SECRET=$(openssl rand -base64 32)
NEXTAUTH_URL=http://$EC2_PUBLIC_IP:3002
DATABASE_URL=mysql://docs_user:\$MYSQL_PASSWORD@localhost:3307/docs_db
EOF

# Update docker-compose with EC2 IP
sed -i "s/YOUR_EC2_PUBLIC_IP/$EC2_PUBLIC_IP/g" docker-compose-ec2.yml

# Build and start services
echo "🐳 Building and starting Docker containers..."
docker-compose -f docker-compose-ec2.yml up -d --build

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check status
echo "📊 Service Status:"
docker-compose -f docker-compose-ec2.yml ps

# Show access URLs
echo ""
echo "✅ Deployment Complete!"
echo "🌐 Next.js App: http://$EC2_PUBLIC_IP:3002"
echo "🔍 Prisma Studio: http://$EC2_PUBLIC_IP:5556"
echo "🗄️  MySQL: $EC2_PUBLIC_IP:3307"
echo ""
echo "📋 To check logs: docker-compose -f docker-compose-ec2.yml logs -f app"
echo "🛑 To stop: docker-compose -f docker-compose-ec2.yml down" 