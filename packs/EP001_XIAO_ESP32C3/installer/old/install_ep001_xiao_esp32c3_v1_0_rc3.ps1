$ErrorActionPreference = "Stop"

Write-Host "EP001 XIAO ESP32C3 v1.0 RC3 broad app.asar patch"
Write-Host ""

$resources = "C:\KidsBlock Desktop\resources"
$appAsar = Join-Path $resources "app.asar"

if (!(Test-Path $appAsar)) {
    Write-Host "ERROR: app.asar not found: $appAsar"
    exit 1
}

try {
    $npxVersion = & npx --version 2>$null
    Write-Host "npx: $npxVersion"
} catch {
    Write-Host "ERROR: npx was not found. Install Node.js first."
    exit 1
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $resources ("app.asar.backup_ep001_rc3_" + $stamp)
Copy-Item $appAsar $backup -Force
Write-Host "Backup created:"
Write-Host $backup

$work = Join-Path $env:TEMP ("kb_ep001_rc3_" + $stamp)
$extractDir = Join-Path $work "app"
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

Write-Host "Extracting app.asar..."
& npx asar extract $appAsar $extractDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: asar extract failed."
    exit 1
}

$bundleFiles = Get-ChildItem -Path $extractDir -Recurse -Include "*.bundle.js","bundle.js","*.js" -File -ErrorAction SilentlyContinue
$total = 0
$filesPatched = 0

foreach ($f in $bundleFiles) {
    $txt = Get-Content $f.FullName -Raw -Encoding UTF8
    $count = ([regex]::Matches($txt, "esp32:esp32:esp32")).Count
    if ($count -gt 0) {
        $txt2 = $txt.Replace("esp32:esp32:esp32", "esp32:esp32:XIAO_ESP32C3")
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($f.FullName, $txt2, $utf8NoBom)
        $total += $count
        $filesPatched++
        Write-Host ("Patched " + $count + " occurrence(s): " + $f.FullName)
    }
}

if ($total -eq 0) {
    Write-Host "ERROR: No esp32:esp32:esp32 occurrences found in extracted app.asar."
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
Write-Host "Patch complete."
Write-Host ("Files patched: " + $filesPatched)
Write-Host ("Total occurrences replaced: " + $total)
Write-Host ""
Write-Host "Run analyzer\v13 after this, then start KidsBlock and test upload."
