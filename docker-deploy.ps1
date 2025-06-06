Write-Host "Starting Docker deployment for Next.js Docs App..." -ForegroundColor Green

# Check if .env.local exists
if (-not (Test-Path ".env.local")) {
    Write-Host "Warning: .env.local file not found!" -ForegroundColor Yellow
    Write-Host "Creating .env.local from template..." -ForegroundColor Cyan
    
    # Generate a random secret
    $secret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))
    
    $envContent = @"
# Database Configuration
DATABASE_URL="mysql://docs_user:docs_password@db:3306/docs_db"

# NextAuth Configuration
NEXTAUTH_SECRET="$secret"
NEXTAUTH_URL="http://localhost:3000"

# Email Configuration (update with your SMTP settings)
EMAIL_SERVER_HOST="smtp.gmail.com"
EMAIL_SERVER_PORT=587
EMAIL_SERVER_USER="your-email@gmail.com"
EMAIL_SERVER_PASSWORD="your-app-password"
EMAIL_FROM="your-email@gmail.com"

# Application Configuration
NODE_ENV="production"
"@
    
    $envContent | Out-File -FilePath ".env.local" -Encoding UTF8
    Write-Host "Success: .env.local created! Please update the email settings if needed." -ForegroundColor Green
}

# Build and start containers
Write-Host "Building Docker containers..." -ForegroundColor Cyan
docker-compose down
docker-compose build --no-cache

Write-Host "Starting containers..." -ForegroundColor Cyan
docker-compose up -d

# Wait for database to be ready
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Run database migrations
Write-Host "Running database migrations..." -ForegroundColor Cyan
docker-compose exec app npx prisma db push

# Run database seeding (optional)
Write-Host "Seeding database..." -ForegroundColor Cyan
docker-compose exec app npm run db:seed

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your app is running at: http://localhost:3000" -ForegroundColor White
Write-Host "Database is running at: localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  - View logs: docker-compose logs -f"
Write-Host "  - Stop containers: docker-compose down"
Write-Host "  - Restart: docker-compose restart"
Write-Host "  - Access app container: docker-compose exec app sh"
Write-Host "  - Access database: docker-compose exec db mysql -u docs_user -p docs_db" 