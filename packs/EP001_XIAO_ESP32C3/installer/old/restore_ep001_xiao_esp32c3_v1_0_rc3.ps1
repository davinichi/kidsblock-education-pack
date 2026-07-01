$ErrorActionPreference = "Stop"
$resources = "C:\KidsBlock Desktop\resources"
$appAsar = Join-Path $resources "app.asar"
$backups = Get-ChildItem -Path $resources -Filter "app.asar.backup_ep001_rc3_*" -File | Sort-Object LastWriteTime -Descending
if ($backups.Count -eq 0) {
    Write-Host "ERROR: No RC3 backup found."
    exit 1
}
Copy-Item $backups[0].FullName $appAsar -Force
Write-Host "Restored from:"
Write-Host $backups[0].FullName
