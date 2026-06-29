$ErrorActionPreference = "Stop"

Write-Host "EP001 XIAO ESP32C3 v1.0 RC2 app.asar patch installer"
Write-Host ""

$resources = "C:\KidsBlock Desktop\resources"
$appAsar = Join-Path $resources "app.asar"

if (!(Test-Path $appAsar)) {
    Write-Host "ERROR: app.asar not found:"
    Write-Host $appAsar
    exit 1
}

try {
    $npxVersion = & npx --version 2>$null
    Write-Host ("npx: " + $npxVersion)
} catch {
    Write-Host "ERROR: npx was not found. Install Node.js first."
    exit 1
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $resources ("app.asar.backup_ep001_rc2_" + $stamp)
Copy-Item $appAsar $backup -Force
Write-Host "Backup created:"
Write-Host $backup

$work = Join-Path $env:TEMP ("kb_ep001_rc2_" + $stamp)
$extractDir = Join-Path $work "app"
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

Write-Host "Extracting app.asar..."
& npx asar extract $appAsar $extractDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: asar extract failed."
    exit 1
}

$bundleFiles = Get-ChildItem -Path $extractDir -Recurse -Include "*.bundle.js","bundle.js" -File -ErrorAction SilentlyContinue
if ($bundleFiles.Count -eq 0) {
    Write-Host "ERROR: bundle js file not found in extracted app.asar."
    exit 1
}

$oldBlock = @"
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:esp32'
};
"@

$newBlock = @"
const DIVECE_OPT = {
  type: 'arduino',
  fqbn: 'esp32:esp32:XIAO_ESP32C3'
};
"@

$patched = 0
foreach ($bundle in $bundleFiles) {
    $txt = Get-Content $bundle.FullName -Raw -Encoding UTF8
    if ($txt.Contains($oldBlock)) {
        $txt2 = $txt.Replace($oldBlock, $newBlock)
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($bundle.FullName, $txt2, $utf8NoBom)
        $patched++
        Write-Host "Patched target block in:"
        Write-Host $bundle.FullName
    }
}

if ($patched -eq 0) {
    Write-Host "ERROR: target DIVECE_OPT block was not found."
    Write-Host "No changes were applied to app.asar."
    exit 1
}

$newAsar = Join-Path $work "app.asar"
Write-Host "Packing patched app.asar..."
& npx asar pack $extractDir $newAsar
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: asar pack failed."
    exit 1
}

Copy-Item $newAsar $appAsar -Force

Write-Host ""
Write-Host "Patched app.asar installed."
Write-Host "Patched bundle file count:"
Write-Host $patched
Write-Host ""
Write-Host "Start KidsBlock and test XIAO ESP32C3 compile/upload."
Write-Host "To restore, run restore_ep001_xiao_esp32c3_v1_0_rc2.bat."
