#!/bin/bash

echo "🚀 Starting Docker deployment for Next.js Docs App..."

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "⚠️  .env.local file not found!"
    echo "📝 Creating .env.local from template..."
    cat > .env.local << EOL
# Database Configuration
DATABASE_URL="mysql://docs_user:docs_password@db:3306/docs_db"

# NextAuth Configuration
NEXTAUTH_SECRET="$(openssl rand -base64 32)"
NEXTAUTH_URL="http://localhost:3000"

# Email Configuration (update with your SMTP settings)
EMAIL_SERVER_HOST="smtp.gmail.com"
EMAIL_SERVER_PORT=587
EMAIL_SERVER_USER="your-email@gmail.com"
EMAIL_SERVER_PASSWORD="your-app-password"
EMAIL_FROM="your-email@gmail.com"

# Application Configuration
NODE_ENV="production"
EOL
    echo "✅ .env.local created! Please update the email settings if needed."
fi

# Build and start containers
echo "🔨 Building Docker containers..."
docker-compose down
docker-compose build --no-cache

echo "🚀 Starting containers..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 30

# Run database migrations
echo "🗄️  Running database migrations..."
docker-compose exec app npx prisma db push

# Run database seeding (optional)
echo "🌱 Seeding database..."
docker-compose exec app npm run db:seed

echo "✅ Deployment complete!"
echo "🌐 Your app is running at: http://localhost:3000"
echo "🗄️  Database is running at: localhost:3306"
echo ""
echo "📋 Useful commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop containers: docker-compose down"
echo "  - Restart: docker-compose restart"
echo "  - Access app container: docker-compose exec app sh"
echo "  - Access database: docker-compose exec db mysql -u docs_user -p docs_db" 