$ErrorActionPreference = 'Stop'
$roaming = [Environment]::GetFolderPath('ApplicationData')
$target = Join-Path $roaming 'KidsBlock\Data\external-resources'
$deviceRoot = Join-Path $target 'devices'
$deviceJs = Join-Path $deviceRoot 'device.js'
$idx = Join-Path $deviceRoot 'XIAOESP32C3\XIAOESP32C3\index.js'

Write-Host 'EP001 XIAO ESP32C3 v0.7 checker'
Write-Host "Target: $target"
Write-Host "device.js exists: $(Test-Path $deviceJs)"
if (Test-Path $deviceJs) {
    $txt = Get-Content -Raw -Encoding UTF8 $deviceJs
    Write-Host "device.js has XIAOESP32C3_arduinoEsp32: $($txt.Contains('XIAOESP32C3_arduinoEsp32'))"
    Write-Host 'XIAO lines:'
    Get-Content -Encoding UTF8 $deviceJs | Where-Object { $_ -match 'XIAO|ESP32C3' } | ForEach-Object { Write-Host $_ }
}
Write-Host "nested device index exists: $(Test-Path $idx)"
if (Test-Path $idx) {
    Get-Content -Encoding UTF8 $idx | Where-Object { $_ -match 'deviceId|deviceExtensions|deviceExtensionsCompatible|module.exports|name:' } | ForEach-Object { Write-Host $_ }
}
