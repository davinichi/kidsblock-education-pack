$ErrorActionPreference = "Stop"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path (Get-Location) ("kidsblock_analyzer_v9_report_" + $ts)
New-Item -ItemType Directory -Path $out -Force | Out-Null

$root = Join-Path $env:APPDATA "KidsBlock\Data\external-resources"
$kitIndex = Join-Path $root "extensions\arduino\kit\XIAOESP32C3\index.js"
$report = Join-Path $out "report.txt"

Add-Content $report "KidsBlock Analyzer v9"
Add-Content $report ("Timestamp: " + $ts)
Add-Content $report ("Active root: " + $root)
Add-Content $report ("XIAO kit index: " + $kitIndex)
Add-Content $report ("Kit index exists: " + (Test-Path $kitIndex))

if (Test-Path $kitIndex) {
    $txt = Get-Content $kitIndex -Raw -Encoding UTF8
    Add-Content $report ("Contains esp32:esp32:XIAO_ESP32C3: " + ($txt -match "esp32:esp32:XIAO_ESP32C3"))
    Add-Content $report ("Contains esp32:esp32:esp32: " + ($txt -match "esp32:esp32:esp32"))
    Add-Content $report ""
    Add-Content $report "FQBN lines:"
    ($txt -split "`n" | Select-String -Pattern "fqbn" | ForEach-Object { Add-Content $report $_.Line })
}

Compress-Archive -Path (Join-Path $out "*") -DestinationPath ($out + ".zip") -Force
Write-Host "Report created:"
Write-Host ($out + ".zip")
