$ErrorActionPreference = "Stop"

Write-Host "EP001 XIAO ESP32C3 v1.0 upload test installer"
$root = Join-Path $env:APPDATA "KidsBlock\Data\external-resources"
$kit = Join-Path $root "extensions\arduino\kit\XIAOESP32C3"
$index = Join-Path $kit "index.js"

if (!(Test-Path $root)) {
    Write-Host "ERROR: active external-resources not found:"
    Write-Host $root
    exit 1
}

if (!(Test-Path $index)) {
    Write-Host "ERROR: XIAOESP32C3 kit index.js not found:"
    Write-Host $index
    Write-Host ""
    Write-Host "Please install EP001 v0.7 or later first."
    exit 1
}

$backup = "$index.bak_ep001_v1_0_upload_test"
if (!(Test-Path $backup)) {
    Copy-Item $index $backup -Force
    Write-Host "Backup created:"
    Write-Host $backup
} else {
    Write-Host "Backup already exists:"
    Write-Host $backup
}

$text = Get-Content $index -Raw -Encoding UTF8

# Replace the generic ESP32 FQBN with XIAO ESP32C3 FQBN.
# This is deliberately narrow: only known ESP32 generic forms are replaced.
$oldText = $text
$text = $text -replace "fqbn\s*:\s*'esp32:esp32:esp32'", "fqbn: 'esp32:esp32:XIAO_ESP32C3'"
$text = $text -replace 'fqbn\s*:\s*"esp32:esp32:esp32"', 'fqbn: "esp32:esp32:XIAO_ESP32C3"'
$text = $text -replace 'fqbn\s*:\s*`esp32:esp32:esp32`', 'fqbn: `esp32:esp32:XIAO_ESP32C3`'

# Add a comment marker if not present.
if ($text -notmatch "EP001 XIAO ESP32C3 upload test") {
    $text = $text -replace "const DIVECE_OPT\s*=\s*\{", "const DIVECE_OPT = {`n    // EP001 XIAO ESP32C3 upload test"
}

if ($oldText -eq $text) {
    Write-Host "WARNING: No FQBN replacement was made."
    Write-Host "The file may already be updated or may use a different format."
} else {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($index, $text, $utf8NoBom)
    Write-Host "Updated:"
    Write-Host $index
}

Write-Host ""
Write-Host "Checking result..."
$check = Get-Content $index -Raw -Encoding UTF8
if ($check -match "esp32:esp32:XIAO_ESP32C3") {
    Write-Host "OK: FQBN is now esp32:esp32:XIAO_ESP32C3"
    exit 0
} else {
    Write-Host "ERROR: FQBN was not updated."
    exit 1
}
