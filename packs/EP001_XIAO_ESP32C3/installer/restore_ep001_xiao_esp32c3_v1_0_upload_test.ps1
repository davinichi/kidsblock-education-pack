$ErrorActionPreference = "Stop"

Write-Host "EP001 XIAO ESP32C3 v1.0 upload test restore"
$index = Join-Path $env:APPDATA "KidsBlock\Data\external-resources\extensions\arduino\kit\XIAOESP32C3\index.js"
$backup = "$index.bak_ep001_v1_0_upload_test"

if (!(Test-Path $backup)) {
    Write-Host "No backup found:"
    Write-Host $backup
    exit 1
}

Copy-Item $backup $index -Force
Write-Host "Restored:"
Write-Host $index
