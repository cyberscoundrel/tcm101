param([string]$IpAddress = "1.2.3.4")

Write-Host "Testing SCP script with IP: $IpAddress" -ForegroundColor Green

# Check for .pem files
$pemFiles = Get-ChildItem -Path "." -Filter "*.pem"
Write-Host "Found $($pemFiles.Count) .pem files" -ForegroundColor Cyan

# Check for .tar files
$tarFiles = Get-ChildItem -Path "." -Filter "*.tar"
Write-Host "Found $($tarFiles.Count) .tar files:" -ForegroundColor Cyan
foreach ($file in $tarFiles) {
    $sizeGB = [math]::Round($file.Length / 1GB, 2)
    Write-Host "  - $($file.Name) ($sizeGB GB)" -ForegroundColor White
}

Write-Host "Test completed!" -ForegroundColor Green 