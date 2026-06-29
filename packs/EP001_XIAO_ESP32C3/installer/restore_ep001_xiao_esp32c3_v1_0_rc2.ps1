$ErrorActionPreference = "Stop"

Write-Host "EP001 XIAO ESP32C3 v1.0 RC2 restore"

$resources = "C:\KidsBlock Desktop\resources"
$appAsar = Join-Path $resources "app.asar"
$backups = Get-ChildItem -Path $resources -Filter "app.asar.backup_ep001_rc2_*" -File | Sort-Object LastWriteTime -Descending

if ($backups.Count -eq 0) {
    Write-Host "ERROR: No RC2 backup found."
    exit 1
}

Copy-Item $backups[0].FullName $appAsar -Force
Write-Host "Restored app.asar from:"
Write-Host $backups[0].FullName
Write-Host "Restart KidsBlock."
