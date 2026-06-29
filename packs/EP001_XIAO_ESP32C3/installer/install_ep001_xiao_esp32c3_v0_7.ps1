$ErrorActionPreference = 'Stop'

Write-Host 'EP001 XIAO ESP32C3 v0.7 display-only installer'

$roaming = [Environment]::GetFolderPath('ApplicationData')
$target = Join-Path $roaming 'KidsBlock\Data\external-resources'
if (!(Test-Path $target)) {
    Write-Host "ERROR: target not found: $target"
    exit 1
}

$deviceRoot = Join-Path $target 'devices'
$deviceJs = Join-Path $deviceRoot 'device.js'
if (!(Test-Path $deviceJs)) {
    Write-Host "ERROR: device.js not found: $deviceJs"
    exit 1
}

$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$packRoot = Split-Path -Parent $base
$srcDevice = Join-Path $packRoot 'source\devices\XIAOESP32C3'
$dstDevice = Join-Path $deviceRoot 'XIAOESP32C3'

$backupDir = Join-Path $packRoot ('backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Copy-Item $deviceJs (Join-Path $backupDir 'device.js.bak') -Force
if (Test-Path $dstDevice) {
    Copy-Item $dstDevice (Join-Path $backupDir 'XIAOESP32C3.bak') -Recurse -Force
    Remove-Item $dstDevice -Recurse -Force
}

Copy-Item $srcDevice $deviceRoot -Recurse -Force

$expected = "    'XIAOESP32C3_arduinoEsp32',"
$lines = Get-Content -Encoding UTF8 $deviceJs
$lines = $lines | Where-Object { $_ -notmatch "XIAO_?ESP32C3_arduinoEsp32" -and $_ -notmatch "XIAOESP32C3_arduinoEsp32" }

$out = New-Object System.Collections.Generic.List[string]
$inserted = $false
foreach ($line in $lines) {
    $out.Add($line)
    if (!$inserted -and $line -match "ESP32S_arduinoEsp32") {
        $out.Add($expected)
        $inserted = $true
    }
}
if (!$inserted) {
    $out.Insert([Math]::Min(1, $out.Count), $expected)
}
Set-Content -Encoding UTF8 -Path $deviceJs -Value $out

Write-Host 'Installed files:'
Write-Host "  $dstDevice\XIAOESP32C3\index.js"
Write-Host 'Updated:'
Write-Host "  $deviceJs"
Write-Host "Backup: $backupDir"
Write-Host ''
Write-Host 'Next: restart KidsBlock and check device list.'
