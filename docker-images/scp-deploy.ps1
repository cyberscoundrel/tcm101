param(
    [Parameter(Mandatory=$true)]
    [string]$IpAddress,
    [string]$Username = "ubuntu",
    [string]$RemoteFolder = "~/tcm101/docker-images"
)

Write-Host "🚀 Starting SCP deployment of Docker images to EC2..." -ForegroundColor Green

# Validate IP format
if ($IpAddress -notmatch "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
    Write-Host "❌ Error: Invalid IP address format: $IpAddress" -ForegroundColor Red
    Write-Host "Usage: .\scp-deploy.ps1 -IpAddress <IP>" -ForegroundColor Yellow
    Write-Host "Example: .\scp-deploy.ps1 -IpAddress 44.211.224.107" -ForegroundColor Yellow
    exit 1
}

Write-Host "📍 Target EC2 IP: $IpAddress" -ForegroundColor Cyan
Write-Host "👤 Username: $Username" -ForegroundColor Cyan
Write-Host "📁 Remote folder: $RemoteFolder" -ForegroundColor Cyan

# Auto-detect .pem file
$pemFiles = Get-ChildItem -Path "." -Filter "*.pem"
if ($pemFiles.Count -eq 0) {
    Write-Host "❌ No .pem key file found!" -ForegroundColor Red
    exit 1
} elseif ($pemFiles.Count -eq 1) {
    $keyFile = $pemFiles[0].Name
    Write-Host "🔑 Using key file: $keyFile" -ForegroundColor Cyan
} else {
    $keyFile = $pemFiles[0].Name
    Write-Host "🔑 Found multiple .pem files, using: $keyFile" -ForegroundColor Cyan
}

# Get .tar files
$tarFiles = Get-ChildItem -Path "." -Filter "*.tar"
if ($tarFiles.Count -eq 0) {
    Write-Host "❌ No .tar files found!" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Found $($tarFiles.Count) .tar file(s):" -ForegroundColor Green
foreach ($file in $tarFiles) {
    $sizeGB = [math]::Round($file.Length / 1GB, 2)
    Write-Host "  - $($file.Name) ($sizeGB GB)" -ForegroundColor White
}

# Copy each .tar file
$totalFiles = $tarFiles.Count
$currentFile = 0

foreach ($tarFile in $tarFiles) {
    $currentFile++
    Write-Host ""
    Write-Host "📤 Copying file $currentFile/$totalFiles`: $($tarFile.Name)" -ForegroundColor Cyan
    
    $startTime = Get-Date
    & scp -i $keyFile $tarFile.Name "ubuntu@${IpAddress}:$RemoteFolder/"
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully copied $($tarFile.Name) in $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to copy $($tarFile.Name)!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "✅ All Docker images copied successfully!" -ForegroundColor Green
Write-Host "🌐 Files copied to: ubuntu@${IpAddress}:$RemoteFolder/" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. SSH: ssh -i $keyFile ubuntu@$IpAddress" -ForegroundColor White
Write-Host "  2. Navigate: cd $RemoteFolder" -ForegroundColor White
Write-Host "  3. Load images: docker load -i *.tar" -ForegroundColor White
Write-Host "  4. Verify: docker images" -ForegroundColor White 