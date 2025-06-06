# Build Docker image from git repository
# Usage: .\build-image.ps1 [repo-url] [tag]

param(
    [string]$RepoUrl = "https://github.com/cyberscoundrel/tcm101.git",
    [string]$Tag = "latest"
)

$ImageName = "docs-app/docs-app"
$TarFileName = "docs-app-${Tag}.tar"

Write-Host "Building Docker image from git repository..." -ForegroundColor Green
Write-Host "Repository: $RepoUrl" -ForegroundColor Cyan
Write-Host "Image: ${ImageName}:$Tag" -ForegroundColor Cyan

# Build the image
Write-Host "Running docker build..." -ForegroundColor Yellow
docker build -f Dockerfile.remote --build-arg "REPO_URL=$RepoUrl" --build-arg "BRANCH=main" -t "${ImageName}:$Tag" -t "${ImageName}:latest" .

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "Image built: ${ImageName}:$Tag" -ForegroundColor Green
    
    # Save image as TAR file
    Write-Host ""
    Write-Host "Saving image as TAR file..." -ForegroundColor Yellow
    docker save -o $TarFileName "${ImageName}:$Tag"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "TAR file created: $TarFileName" -ForegroundColor Green
        $TarSize = (Get-Item $TarFileName).Length / 1MB
        Write-Host "TAR file size: $([math]::Round($TarSize, 2)) MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To transfer to EC2:" -ForegroundColor Yellow
        Write-Host "   scp -i your-key.pem $TarFileName ec2-user@your-ec2-ip:/home/ec2-user/" -ForegroundColor White
        Write-Host ""
        Write-Host "On EC2, load the image:" -ForegroundColor Yellow
        Write-Host "   docker load -i $TarFileName" -ForegroundColor White
        Write-Host "   docker run -d -p 3002:3000 -p 5556:5556 ${ImageName}:$Tag" -ForegroundColor White
    } else {
        Write-Host "Failed to create TAR file!" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Alternative - To push to Docker Hub:" -ForegroundColor Yellow
    Write-Host "   docker push ${ImageName}:$Tag" -ForegroundColor White
    Write-Host "   docker push ${ImageName}:latest" -ForegroundColor White
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
} 