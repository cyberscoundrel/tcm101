#!/bin/bash

# EC2 Deployment Script for Next.js Docker App
echo "🚀 Starting EC2 deployment..."

# Get EC2 public IP
EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "📍 EC2 Public IP: $EC2_PUBLIC_IP"

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