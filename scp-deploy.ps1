param(
    [Parameter(Mandatory=$true)]
    [string]$IpAddress,
    [string]$KeyFile = "",
    [string]$Username = "ec2-user",
    [string]$RemoteFolder = "class"
)

Write-Host "🚀 Starting SCP deployment to EC2..." -ForegroundColor Green

# Validate IP format
if ($IpAddress -notmatch "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
    Write-Host "❌ Error: Invalid IP address format: $IpAddress" -ForegroundColor Red
    Write-Host "Usage: .\scp-deploy.ps1 -IpAddress <IP> [-KeyFile <path>] [-Username <user>] [-RemoteFolder <folder>]" -ForegroundColor Yellow
    Write-Host "Example: .\scp-deploy.ps1 -IpAddress 54.123.45.67 -KeyFile C:\path\to\key.pem" -ForegroundColor Yellow
    exit 1
}

Write-Host "📍 Target EC2 IP: $IpAddress" -ForegroundColor Cyan
Write-Host "👤 Username: $Username" -ForegroundColor Cyan
Write-Host "📁 Remote folder: $RemoteFolder" -ForegroundColor Cyan

# Check if key file is provided and exists
$scpOptions = ""
if ($KeyFile -ne "") {
    if (-not (Test-Path $KeyFile)) {
        Write-Host "❌ Error: Key file not found: $KeyFile" -ForegroundColor Red
        exit 1
    }
    $scpOptions = "-i `"$KeyFile`""
    Write-Host "🔑 Using key file: $KeyFile" -ForegroundColor Cyan
}

# Get current directory name for remote folder
$currentDir = Split-Path -Leaf (Get-Location)
Write-Host "📂 Current directory: $currentDir" -ForegroundColor Cyan

# Create exclusion list for files/folders we don't want to copy
$excludeList = @(
    "node_modules",
    ".next",
    ".git",
    "*.log",
    ".env.local",
    ".env",
    "docker-images/*.tar"
)

Write-Host "🚫 Excluding: $($excludeList -join ', ')" -ForegroundColor Yellow

# Create rsync command (rsync is more efficient than scp for directories)
# Note: On Windows, you might need WSL or install rsync separately
$rsyncAvailable = Get-Command rsync -ErrorAction SilentlyContinue
if ($rsyncAvailable) {
    Write-Host "📦 Using rsync for efficient transfer..." -ForegroundColor Cyan
    
    # Build exclude parameters
    $excludeParams = $excludeList | ForEach-Object { "--exclude=$_" }
    $excludeString = $excludeParams -join " "
    
    # Rsync command
    $rsyncCmd = "rsync -avz --progress $excludeString"
    if ($KeyFile -ne "") {
        $rsyncCmd += " -e `"ssh -i '$KeyFile'`""
    }
    $rsyncCmd += " ./ $Username@${IpAddress}:$RemoteFolder/"
    
    Write-Host "🔄 Running: $rsyncCmd" -ForegroundColor Gray
    Invoke-Expression $rsyncCmd
} else {
    Write-Host "📦 Using SCP for transfer..." -ForegroundColor Cyan
    Write-Host "⚠️  Note: For large directories, consider installing rsync for better performance" -ForegroundColor Yellow
    
    # Create temporary directory structure without excluded items
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    $tempPath = Join-Path $tempDir.FullName $currentDir
    New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
    
    Write-Host "📋 Copying files to temporary directory..." -ForegroundColor Cyan
    
    # Copy files excluding the unwanted items
    Get-ChildItem -Path . -Recurse | Where-Object {
        $relativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
        $shouldExclude = $false
        foreach ($exclude in $excludeList) {
            if ($relativePath -like $exclude -or $relativePath.Split('\')[0] -in @('node_modules', '.next', '.git')) {
                $shouldExclude = $true
                break
            }
        }
        -not $shouldExclude
    } | ForEach-Object {
        $destPath = Join-Path $tempPath ($_.FullName.Substring((Get-Location).Path.Length + 1))
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        if (-not $_.PSIsContainer) {
            Copy-Item $_.FullName $destPath
        }
    }
    
    # SCP command to copy the temporary directory
    $scpCmd = "scp $scpOptions -r `"$($tempDir.FullName)/$currentDir`" $Username@${IpAddress}:~/"
    
    Write-Host "🔄 Running: $scpCmd" -ForegroundColor Gray
    Invoke-Expression $scpCmd
    
    # Cleanup temporary directory
    Remove-Item $tempDir.FullName -Recurse -Force
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SCP deployment completed successfully!" -ForegroundColor Green
    Write-Host "🌐 Files copied to: $Username@${IpAddress}:$RemoteFolder/" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "📋 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. SSH into your EC2 instance: ssh $scpOptions $Username@$IpAddress" -ForegroundColor White
    Write-Host "  2. Navigate to the directory: cd $RemoteFolder" -ForegroundColor White
    Write-Host "  3. Run your deployment script: ./deploy-ec2.sh $IpAddress" -ForegroundColor White
} else {
    Write-Host "❌ SCP deployment failed!" -ForegroundColor Red
    Write-Host "Please check your network connection, credentials, and target server." -ForegroundColor Yellow
    exit 1
} 