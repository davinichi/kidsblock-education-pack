$ErrorActionPreference = 'Stop'

function Add-Line($s) { Add-Content -Encoding UTF8 -Path $script:ReportFile -Value $s }
function Test-FileTextContains($path, $text) {
    if (!(Test-Path $path)) { return $false }
    $content = Get-Content -Raw -Encoding UTF8 $path
    return $content.Contains($text)
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$reportDir = Join-Path $base "report_v5_$timestamp"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$script:ReportFile = Join-Path $reportDir 'analysis.txt'

$roaming = [Environment]::GetFolderPath('ApplicationData')
$candidates = @(
    (Join-Path $roaming 'KidsBlock\Data\external-resources'),
    (Join-Path $roaming 'KidsBlock\external-resources'),
    'C:\KidsBlock Desktop\resources\external-resources'
)

Add-Line 'KidsBlock Analyzer v5'
Add-Line '====================='
Add-Line "Timestamp: $timestamp"
Add-Line "APPDATA: $roaming"
Add-Line ''

$active = $null
foreach ($c in $candidates) {
    $deviceJs = Join-Path $c 'devices\device.js'
    $exists = Test-Path $deviceJs
    Add-Line "Candidate: $c"
    Add-Line "  device.js: $exists"
    if ($exists -and $null -eq $active) { $active = $c }
}

Add-Line ''
Add-Line "ACTIVE_CANDIDATE: $active"

if ($null -eq $active) {
    Add-Line 'ERROR: No external-resources candidate found.'
} else {
    $deviceRoot = Join-Path $active 'devices'
    $deviceJs = Join-Path $deviceRoot 'device.js'
    $kitRoot = Join-Path $active 'extensions\arduino\kit'

    Add-Line ''
    Add-Line 'Device loader expectation'
    Add-Line '-------------------------'
    Add-Line 'Expected device path format:'
    Add-Line '  devices/<catalog>/<device>/index.js'
    Add-Line ''

    $ids = @()
    $txt = Get-Content -Raw -Encoding UTF8 $deviceJs
    foreach ($m in [regex]::Matches($txt, "'([^']+)'")) {
        $ids += $m.Groups[1].Value
    }
    Add-Line "device.js item count: $($ids.Count)"

    Add-Line ''
    Add-Line 'ESP32-related IDs in device.js:'
    foreach ($id in $ids | Where-Object { $_ -match 'ESP32|Esp32|esp32|8266|XIAO' }) {
        Add-Line "  $id"
    }

    Add-Line ''
    Add-Line 'Nested device index check:'
    $deviceIndexes = Get-ChildItem -Path $deviceRoot -Recurse -Filter index.js -ErrorAction SilentlyContinue
    foreach ($idx in $deviceIndexes) {
        $rel = $idx.FullName.Substring($deviceRoot.Length + 1)
        if ($rel -match 'ESP32|Esp32|esp32|8266|XIAO') {
            Add-Line "  $rel"
        }
    }

    Add-Line ''
    Add-Line 'XIAOESP32C3 expected state:'
    $expectedId = 'XIAOESP32C3_arduinoEsp32'
    $expectedDeviceIndex = Join-Path $deviceRoot 'XIAOESP32C3\XIAOESP32C3\index.js'
    $oldShallowIndex = Join-Path $deviceRoot 'XIAOESP32C3\index.js'
    $expectedKitIndex = Join-Path $kitRoot 'XIAOESP32C3\index.js'
    Add-Line "  device.js has $expectedId: $($ids -contains $expectedId)"
    Add-Line "  nested device index exists: $(Test-Path $expectedDeviceIndex)"
    Add-Line "  shallow device index exists: $(Test-Path $oldShallowIndex)"
    Add-Line "  kit index exists: $(Test-Path $expectedKitIndex)"
    Add-Line "  nested device index has deviceId: $(Test-FileTextContains $expectedDeviceIndex $expectedId)"
    Add-Line "  kit index has supportDevice: $(Test-FileTextContains $expectedKitIndex $expectedId)"
}

Compress-Archive -Path (Join-Path $reportDir '*') -DestinationPath (Join-Path $base "kidsblock_analyzer_v5_report_$timestamp.zip") -Force
Write-Host "Report created: $reportDir"
Write-Host "ZIP created: $(Join-Path $base "kidsblock_analyzer_v5_report_$timestamp.zip")"
