$ErrorActionPreference = 'Continue'

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$base = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) ("report_v7_" + $ts)
New-Item -ItemType Directory -Force -Path $base | Out-Null

function Write-Text($rel, $text) {
    $path = Join-Path $base $rel
    $dir = Split-Path -Parent $path
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $text, $enc)
}

function Copy-IfExists($src, $rel) {
    if (Test-Path $src) {
        $dst = Join-Path $base $rel
        $dir = Split-Path -Parent $dst
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Copy-Item $src $dst -Force
    }
}

function Add-LineContext($file, $patterns, $before=2, $after=4) {
    $out = New-Object System.Collections.Generic.List[string]
    if (!(Test-Path $file)) { return "MISSING: $file`r`n" }
    $out.Add("FILE=$file")
    $lines = Get-Content -Encoding UTF8 $file -ErrorAction SilentlyContinue
    for ($i=0; $i -lt $lines.Count; $i++) {
        foreach ($pat in $patterns) {
            if ($lines[$i] -match $pat) {
                $out.Add("--- match line " + ($i+1) + " pattern=" + $pat)
                $s = [Math]::Max(0, $i-$before)
                $e = [Math]::Min($lines.Count-1, $i+$after)
                for ($j=$s; $j -le $e; $j++) { $out.Add(("{0}: {1}" -f ($j+1), $lines[$j])) }
            }
        }
    }
    return ($out -join "`r`n") + "`r`n"
}

$roaming = [Environment]::GetFolderPath('ApplicationData')
$local = [Environment]::GetFolderPath('LocalApplicationData')
$user = [Environment]::GetFolderPath('UserProfile')
$installRoots = @(
    'C:\KidsBlock Desktop',
    (Join-Path $local 'Programs\KidsBlock Desktop'),
    (Join-Path $local 'Programs\KidsBlock')
) | Where-Object { Test-Path $_ }
$active = Join-Path $roaming 'KidsBlock\Data\external-resources'

$summary = New-Object System.Collections.Generic.List[string]
$summary.Add('KidsBlock Analyzer v7')
$summary.Add('Generated: ' + (Get-Date))
$summary.Add('')
$summary.Add('Environment')
$summary.Add('APPDATA=' + $roaming)
$summary.Add('LOCALAPPDATA=' + $local)
$summary.Add('USERPROFILE=' + $user)
$summary.Add('')
$summary.Add('Install roots')
foreach ($r in $installRoots) { $summary.Add($r) }
$summary.Add('')
$summary.Add('Active external resources: ' + $active + ' exists=' + (Test-Path $active))
Write-Text 'summary.txt' ($summary -join "`r`n")

# Active external resources files for EP001 and reference ESP32S.
Copy-IfExists (Join-Path $active 'devices\device.js') 'active_external_resources\devices\device.js'
Copy-IfExists (Join-Path $active 'devices\XIAOESP32C3\XIAOESP32C3\index.js') 'active_external_resources\devices\XIAOESP32C3_index_nested.js'
Copy-IfExists (Join-Path $active 'devices\XIAOESP32C3\index.js') 'active_external_resources\devices\XIAOESP32C3_index_flat.js'
Copy-IfExists (Join-Path $active 'devices\ESP32S\ESP32S\index.js') 'active_external_resources\devices\ESP32S_index_nested.js'
Copy-IfExists (Join-Path $active 'extensions\arduino\kit\XIAOESP32C3\index.js') 'active_external_resources\kit\XIAOESP32C3_index.js'
Copy-IfExists (Join-Path $active 'extensions\arduino\kit\ESP32S\index.js') 'active_external_resources\kit\ESP32S_index.js'

# Collect ESP32 hardware files from bundled and Arduino15 locations.
$hwRoots = @()
foreach ($root in $installRoots) {
    $p = Join-Path $root 'resources\tools\Arduino\packages\esp32\hardware\esp32'
    if (Test-Path $p) { $hwRoots += Get-ChildItem -Path $p -Directory -ErrorAction SilentlyContinue }
}
$p2 = Join-Path $local 'Arduino15\packages\esp32\hardware\esp32'
if (Test-Path $p2) { $hwRoots += Get-ChildItem -Path $p2 -Directory -ErrorAction SilentlyContinue }
$idx = 0
foreach ($hw in ($hwRoots | Sort-Object FullName -Unique)) {
    $idx++
    $rel = 'hardware\esp32_' + $idx + '_' + ($hw.Name -replace '[^A-Za-z0-9_.-]', '_')
    Copy-IfExists (Join-Path $hw.FullName 'boards.txt') (Join-Path $rel 'boards.txt')
    Copy-IfExists (Join-Path $hw.FullName 'platform.txt') (Join-Path $rel 'platform.txt')
    Copy-IfExists (Join-Path $hw.FullName 'programmers.txt') (Join-Path $rel 'programmers.txt')

    $ctx = ''
    $ctx += Add-LineContext (Join-Path $hw.FullName 'boards.txt') @('^esp32\.', '^XIAO_ESP32C3\.', '^seeed_xiao_esp32c3\.', '^XIAOESP32C3\.') 1 2
    $ctx += "`r`n--- PLATFORM UPLOAD CONTEXT ---`r`n"
    $ctx += Add-LineContext (Join-Path $hw.FullName 'platform.txt') @('upload\.pattern', '--chip', 'build\.mcu', 'esptool', 'recipe\.objcopy') 2 5
    Write-Text (Join-Path $rel 'context.txt') $ctx
}

# Scan app/resource JS files for upload and FQBN clues. Keep context only, not full source.
$scanPatterns = @('esp32:esp32:esp32','arduino-cli','upload','compile','fqbn','FQBN','--chip','esptool','boardType','deviceExtensionsCompatible')
$scanOut = New-Object System.Collections.Generic.List[string]
foreach ($root in $installRoots) {
    $res = Join-Path $root 'resources'
    if (!(Test-Path $res)) { continue }
    $files = Get-ChildItem -Path $res -Recurse -File -Include *.js,*.json,*.ts,*.txt -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $txt = Get-Content -Raw -Encoding UTF8 $f.FullName -ErrorAction SilentlyContinue
        if ($null -eq $txt) { continue }
        $hit = $false
        foreach ($pat in $scanPatterns) { if ($txt -match [regex]::Escape($pat)) { $hit = $true; break } }
        if ($hit) {
            $scanOut.Add('FILE=' + $f.FullName)
            foreach ($pat in $scanPatterns) {
                if ($txt -match [regex]::Escape($pat)) { $scanOut.Add('contains ' + $pat) }
            }
            $scanOut.Add('')
        }
    }
}
Write-Text 'resource_upload_scan.txt' ($scanOut -join "`r`n")

# Tool versions and arduino-cli config if possible.
$toolOut = New-Object System.Collections.Generic.List[string]
foreach ($root in $installRoots) {
    $cli = Join-Path $root 'resources\tools\Arduino\arduino-cli.exe'
    if (Test-Path $cli) {
        $toolOut.Add('arduino-cli=' + $cli)
        try { $toolOut.Add((& $cli version 2>&1 | Out-String)) } catch { $toolOut.Add('version failed: ' + $_.Exception.Message) }
        try { $toolOut.Add('config dump:'); $toolOut.Add((& $cli config dump 2>&1 | Out-String)) } catch { $toolOut.Add('config dump failed: ' + $_.Exception.Message) }
        try { $toolOut.Add('board listall esp32:'); $toolOut.Add((& $cli board listall esp32 2>&1 | Out-String)) } catch { $toolOut.Add('board listall failed: ' + $_.Exception.Message) }
    }
}
Write-Text 'tools_and_cli.txt' ($toolOut -join "`r`n")

$zip = Join-Path (Split-Path -Parent $base) ("kidsblock_analyzer_v7_report_" + $ts + ".zip")
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $base '*') -DestinationPath $zip -Force
Write-Host ''
Write-Host 'Analyzer v7 completed.'
Write-Host "Report ZIP: $zip"
