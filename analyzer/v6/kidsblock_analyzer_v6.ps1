$ErrorActionPreference = 'SilentlyContinue'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$base = Join-Path $PSScriptRoot ("kidsblock_analyzer_v6_report_" + $stamp)
New-Item -ItemType Directory -Force -Path $base | Out-Null

function Write-Text($name, $text) {
    $path = Join-Path $base $name
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $text | Out-File -FilePath $path -Encoding UTF8
}

function Copy-IfExists($path, $rel) {
    if (Test-Path $path) {
        $dest = Join-Path $base $rel
        $dir = Split-Path $dest -Parent
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Copy-Item $path $dest -Force
    }
}

$report = New-Object System.Collections.Generic.List[string]
$report.Add('KidsBlock Analyzer v6')
$report.Add('Generated: ' + (Get-Date))
$report.Add('')
$report.Add('Environment')
$report.Add('APPDATA=' + $env:APPDATA)
$report.Add('LOCALAPPDATA=' + $env:LOCALAPPDATA)
$report.Add('USERPROFILE=' + $env:USERPROFILE)
$report.Add('')

$candidates = @(
    'C:\KidsBlock Desktop',
    (Join-Path $env:LOCALAPPDATA 'Programs\KidsBlock Desktop'),
    (Join-Path $env:LOCALAPPDATA 'Programs\KidsBlock'),
    (Join-Path $env:APPDATA 'KidsBlock'),
    (Join-Path $env:APPDATA 'KidsBlock\Data')
)

$report.Add('Candidate paths')
foreach ($c in $candidates) { $report.Add((Test-Path $c).ToString() + '  ' + $c) }
$report.Add('')

$activeExt = Join-Path $env:APPDATA 'KidsBlock\Data\external-resources'
$report.Add('Active external-resources candidate: ' + $activeExt)
$report.Add('Exists: ' + (Test-Path $activeExt))
$report.Add('')

# Active XIAO files
$xiaodev = Join-Path $activeExt 'devices\XIAOESP32C3\XIAOESP32C3\index.js'
$xiaokit = Join-Path $activeExt 'extensions\arduino\kit\XIAOESP32C3\index.js'
$devicejs = Join-Path $activeExt 'devices\device.js'
$report.Add('EP001 files')
$report.Add('device.js: ' + (Test-Path $devicejs))
$report.Add('XIAO device index: ' + (Test-Path $xiaodev))
$report.Add('XIAO kit index: ' + (Test-Path $xiaokit))
$report.Add('')
Copy-IfExists $devicejs 'active_external_resources/devices/device.js'
Copy-IfExists $xiaodev 'active_external_resources/devices/XIAOESP32C3_index.js'
Copy-IfExists $xiaokit 'active_external_resources/extensions/arduino/kit/XIAOESP32C3_index.js'

# Search for boards.txt and platform.txt in likely locations
$searchRoots = @(
    'C:\KidsBlock Desktop',
    (Join-Path $env:APPDATA 'KidsBlock'),
    (Join-Path $env:LOCALAPPDATA 'Arduino15'),
    (Join-Path $env:USERPROFILE 'AppData\Local\Arduino15'),
    (Join-Path $env:USERPROFILE 'Documents\Arduino'),
    (Join-Path $env:USERPROFILE 'AppData\Local\Programs')
) | Select-Object -Unique

$boards = @()
$platforms = @()
foreach ($r in $searchRoots) {
    if (Test-Path $r) {
        $boards += Get-ChildItem -Path $r -Filter 'boards.txt' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
        $platforms += Get-ChildItem -Path $r -Filter 'platform.txt' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
}
$boards = $boards | Select-Object -Unique
$platforms = $platforms | Select-Object -Unique

$report.Add('boards.txt files')
foreach ($b in $boards) { $report.Add($b) }
$report.Add('')
$report.Add('platform.txt files')
foreach ($p in $platforms) { $report.Add($p) }
$report.Add('')

$i = 0
foreach ($b in $boards) {
    $i++
    $txt = Get-Content $b -Raw -Encoding UTF8
    $info = New-Object System.Collections.Generic.List[string]
    $info.Add('FILE=' + $b)
    $info.Add('HAS_XIAO_ESP32C3=' + ($txt -match 'XIAO_ESP32C3|Seeed_XIAO_ESP32C3|xiao.*esp32c3|ESP32C3' ))
    $info.Add('HAS_ESP32_BOARD=' + ($txt -match '(?m)^esp32\.name='))
    $info.Add('')
    $patterns = @('XIAO_ESP32C3','Seeed','esp32c3','ESP32C3','esp32.name','esp32.upload','esp32.build')
    foreach ($pat in $patterns) {
        $info.Add('--- matches: ' + $pat)
        $matches = Select-String -Path $b -Pattern $pat -SimpleMatch -Context 2,2 -ErrorAction SilentlyContinue
        foreach ($m in $matches | Select-Object -First 50) {
            $info.Add(('Line {0}: {1}' -f $m.LineNumber, $m.Line.Trim()))
            foreach ($c in $m.Context.PreContext) { $info.Add('  pre: ' + $c.Trim()) }
            foreach ($c in $m.Context.PostContext) { $info.Add('  post: ' + $c.Trim()) }
        }
        $info.Add('')
    }
    Write-Text ("boards/boards_$i.txt") $info
}

# Search app.asar/bundles for fqbn strings without copying huge asar
$installRoots = @('C:\KidsBlock Desktop', (Join-Path $env:LOCALAPPDATA 'Programs\KidsBlock Desktop'))
$fqbnInfo = New-Object System.Collections.Generic.List[string]
foreach ($r in $installRoots) {
    if (Test-Path $r) {
        $files = Get-ChildItem -Path $r -Include '*.js','*.asar' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 2000
        foreach ($f in $files) {
            try {
                $content = Get-Content $f.FullName -Raw -Encoding UTF8
                if ($content -match 'esp32:esp32:esp32|arduinoEsp32|DIVECE_OPT|DEVICE_OPT|fqbn') {
                    $fqbnInfo.Add('FILE=' + $f.FullName)
                    foreach ($m in [regex]::Matches($content, "fqbn.{0,80}")) { $fqbnInfo.Add($m.Value) }
                    if ($content -match "esp32:esp32:esp32") { $fqbnInfo.Add('contains esp32:esp32:esp32') }
                    if ($content -match "arduinoEsp32") { $fqbnInfo.Add('contains arduinoEsp32') }
                    $fqbnInfo.Add('')
                }
            } catch {}
        }
    }
}
Write-Text 'app_fqbn_scan.txt' $fqbnInfo

# Arduino CLI / tool info
$toolInfo = New-Object System.Collections.Generic.List[string]
$exeNames = @('arduino-cli.exe','esptool.exe','python.exe','python3.exe')
foreach ($r in $searchRoots) {
    if (Test-Path $r) {
        foreach ($e in $exeNames) {
            $found = Get-ChildItem -Path $r -Filter $e -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
            foreach ($x in $found) { $toolInfo.Add($x) }
        }
    }
}
Write-Text 'tools_found.txt' $toolInfo

Write-Text 'summary.txt' $report

$zipPath = Join-Path (Split-Path $base -Parent) ("kidsblock_analyzer_v6_report_" + $stamp + ".zip")
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $base '*') -DestinationPath $zipPath -Force
Write-Host ''
Write-Host 'Analyzer v6 complete.'
Write-Host 'Report ZIP:' $zipPath
