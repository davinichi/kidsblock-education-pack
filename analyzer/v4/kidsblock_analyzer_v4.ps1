$ErrorActionPreference = "Stop"

function Write-TextFile($path, $text) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    Set-Content -Path $path -Value $text -Encoding UTF8
}

function Read-FileSafe($path) {
    if (Test-Path $path) { return Get-Content -Path $path -Raw -Encoding UTF8 }
    return ""
}

function Find-KidsBlockCandidates {
    $list = @()
    $appdata = [Environment]::GetFolderPath("ApplicationData")
    $c1 = Join-Path $appdata "KidsBlock\Data\external-resources"
    $c2 = Join-Path $appdata "KidsBlock\external-resources"
    $c3 = "C:\KidsBlock Desktop\resources\external-resources"
    foreach ($c in @($c1,$c2,$c3)) {
        $list += [PSCustomObject]@{ Path=$c; Exists=(Test-Path $c) }
    }
    return $list
}

function Get-DeviceJsEntries($deviceJs) {
    $txt = Read-FileSafe $deviceJs
    $entries = @()
    foreach ($m in [regex]::Matches($txt, "'([^']+)'")) {
        $entries += $m.Groups[1].Value
    }
    return $entries
}

function Get-ValueFromJs($txt, $name) {
    $pattern1 = $name + "\s*:\s*'([^']+)'"
    $m = [regex]::Match($txt, $pattern1)
    if ($m.Success) { return $m.Groups[1].Value }
    return ""
}

function Get-ArrayFromJs($txt, $name) {
    $result = @()
    $pattern = $name + "\s*:\s*\[([^\]]*)\]"
    $m = [regex]::Match($txt, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($m.Success) {
        foreach ($q in [regex]::Matches($m.Groups[1].Value, "'([^']+)'") ) {
            $result += $q.Groups[1].Value
        }
    }
    return $result
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$base = Split-Path $MyInvocation.MyCommand.Path -Parent
$out = Join-Path $base "report\kidsblock_analyzer_v4_report_$stamp"
New-Item -ItemType Directory -Path $out -Force | Out-Null

$candidates = Find-KidsBlockCandidates
$active = $candidates | Where-Object { $_.Exists -and (Test-Path (Join-Path $_.Path "devices\device.js")) } | Select-Object -First 1

$summary = @()
$summary += "KidsBlock Analyzer v4"
$summary += "Timestamp: $stamp"
$summary += ""
$summary += "Candidates:"
foreach ($c in $candidates) { $summary += ("- {0} : {1}" -f $c.Path, $c.Exists) }
$summary += ""
if ($active) { $summary += "ACTIVE_CANDIDATE: $($active.Path)" } else { $summary += "ACTIVE_CANDIDATE: NOT FOUND" }

if ($active) {
    $root = $active.Path
    $deviceJs = Join-Path $root "devices\device.js"
    $entries = Get-DeviceJsEntries $deviceJs
    $summary += ""
    $summary += "device.js entries: $($entries.Count)"
    $summary += ""
    $summary += "ESP32-related entries:"
    foreach ($e in ($entries | Where-Object { $_ -match "ESP32|Esp32|esp32|XIAO" })) { $summary += "- $e" }

    $matrix = @()
    foreach ($e in $entries) {
        if ($e -match "^(.+?)_(arduino.+)$") {
            $devName = $Matches[1]
            $compat = $Matches[2]
            $devPath = Join-Path $root ("devices\" + $devName + "\index.js")
            $kitPath = Join-Path $root ("extensions\arduino\kit\" + $devName + "\index.js")
            $devTxt = Read-FileSafe $devPath
            $kitTxt = Read-FileSafe $kitPath
            $deviceId = Get-ValueFromJs $devTxt "deviceId"
            $deviceExtensions = Get-ArrayFromJs $devTxt "deviceExtensions"
            $deviceCompatible = Get-ValueFromJs $devTxt "deviceExtensionsCompatible"
            $extensionId = Get-ValueFromJs $kitTxt "extensionId"
            $supportDevice = Get-ArrayFromJs $kitTxt "supportDevice"
            $matrix += [PSCustomObject]@{
                entry=$e
                deviceFolder=(Test-Path (Split-Path $devPath -Parent))
                deviceIndex=(Test-Path $devPath)
                deviceId=$deviceId
                deviceExtensions=($deviceExtensions -join ",")
                deviceCompatible=$deviceCompatible
                kitFolder=(Test-Path (Split-Path $kitPath -Parent))
                kitIndex=(Test-Path $kitPath)
                extensionId=$extensionId
                supportDevice=($supportDevice -join ",")
            }
        }
    }
    $matrix | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $out "device_extension_matrix.json") -Encoding UTF8
    $matrix | Export-Csv -Path (Join-Path $out "device_extension_matrix.csv") -Encoding UTF8 -NoTypeInformation

    Copy-Item $deviceJs (Join-Path $out "device.js.txt") -Force
}

Write-TextFile (Join-Path $out "summary.txt") ($summary -join "`r`n")

$zip = Join-Path (Split-Path $out -Parent) ("kidsblock_analyzer_v4_report_$stamp.zip")
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $out -DestinationPath $zip -Force
Write-Host "Report created: $zip"
