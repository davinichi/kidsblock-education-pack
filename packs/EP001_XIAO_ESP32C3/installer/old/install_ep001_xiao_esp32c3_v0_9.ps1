$ErrorActionPreference = 'Stop'
Write-Host 'EP001 XIAO ESP32C3 v0.9 upload alias test installer'
Write-Host 'This is experimental and reversible.'
Write-Host ''

function Write-Utf8NoBom($path, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $text, $enc)
}

# 1. Ensure active user-data device registration exists.
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
if (!(Test-Path $srcDevice)) {
    Write-Host "ERROR: source device not found: $srcDevice"
    exit 1
}

$backupDir = Join-Path $packRoot ('backup_v0_9_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
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
if (!$inserted) { $out.Insert([Math]::Min(1, $out.Count), $expected) }
Set-Content -Encoding UTF8 -Path $deviceJs -Value $out

# 2. Patch bundled ESP32 boards.txt safely.
$candidates = @(
    'C:\KidsBlock Desktop',
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock Desktop'),
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock')
)
$roots = @()
foreach ($c in $candidates) { if (Test-Path $c) { $roots += $c } }
if ($roots.Count -eq 0) {
    Write-Host 'ERROR: KidsBlock Desktop install folder was not found.'
    exit 1
}

$boardsFiles = @()
foreach ($root in $roots) {
    $p = Join-Path $root 'resources\tools\Arduino\packages\esp32\hardware\esp32'
    if (Test-Path $p) { $boardsFiles += Get-ChildItem -Path $p -Recurse -Filter 'boards.txt' -File }
}
$boardsFiles = $boardsFiles | Sort-Object FullName -Unique
if ($boardsFiles.Count -eq 0) {
    Write-Host 'ERROR: bundled ESP32 boards.txt was not found.'
    exit 1
}

$begin = '# EP001_XIAO_ESP32C3_ALIAS_BEGIN'
$end = '# EP001_XIAO_ESP32C3_ALIAS_END'
$patched = 0
foreach ($bf in $boardsFiles) {
    $boardsPath = $bf.FullName
    $text = [System.IO.File]::ReadAllText($boardsPath)

    $originalBackup = "$boardsPath.ep001_xiao_original.bak"
    if (!(Test-Path $originalBackup)) {
        Copy-Item $boardsPath $originalBackup -Force
        Write-Host "Backup created: $originalBackup"
    } else {
        Write-Host "Backup already exists: $originalBackup"
    }

    # Remove previous alias block.
    $pattern = [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + "\r?\n?"
    $text = [regex]::Replace($text, $pattern, '', 'Singleline')

    if ($text -notmatch '(?m)^XIAO_ESP32C3\.') {
        Write-Host "SKIP: XIAO_ESP32C3 section not found in $boardsPath"
        Write-Utf8NoBom $boardsPath $text
        continue
    }

    $xiaoLines = @()
    foreach ($line in ($text -split "`r?`n")) {
        if ($line -match '^XIAO_ESP32C3\.') {
            $xiaoLines += ($line -replace '^XIAO_ESP32C3\.', 'esp32.')
        }
    }
    if ($xiaoLines.Count -eq 0) { continue }

    $alias = @()
    $alias += ''
    $alias += $begin
    $alias += '# Temporary alias for EP001 v0.9 upload test.'
    $alias += '# The built-in arduinoEsp32 extension is hardcoded to FQBN esp32:esp32:esp32.'
    $alias += '# These duplicate esp32.* keys make that FQBN use XIAO ESP32C3 parameters.'
    $alias += $xiaoLines
    $alias += $end
    $alias += ''

    $newText = $text.TrimEnd() + "`r`n" + ($alias -join "`r`n") + "`r`n"
    Write-Utf8NoBom $boardsPath $newText
    Write-Host "Patched without BOM: $boardsPath"
    $patched++
}

Write-Host "Patched boards.txt count: $patched"
Write-Host 'Restart KidsBlock and test compile/upload.'
Write-Host 'To restore, run restore_ep001_xiao_esp32c3_v0_9.bat.'
