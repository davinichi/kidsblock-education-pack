$ErrorActionPreference = "Continue"
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path (Get-Location) ("kidsblock_analyzer_v13_rc3_report_" + $ts)
New-Item -ItemType Directory -Path $out -Force | Out-Null
$report = Join-Path $out "report.txt"
$appAsar = "C:\KidsBlock Desktop\resources\app.asar"

Add-Content $report "KidsBlock Analyzer v13 - RC3 app.asar check"
Add-Content $report ("Generated: " + (Get-Date))
Add-Content $report ("app.asar exists: " + (Test-Path $appAsar))

try {
    $npxVersion = & npx --version 2>$null
    Add-Content $report ("npx: " + $npxVersion)
} catch {
    Add-Content $report "npx: not found"
}

if (Test-Path $appAsar) {
    $work = Join-Path $env:TEMP ("kb_analyzer_v13_" + $ts)
    $extractDir = Join-Path $work "app"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    & npx asar extract $appAsar $extractDir
    Add-Content $report ("asar extract exit code: " + $LASTEXITCODE)

    if ($LASTEXITCODE -eq 0) {
        $files = Get-ChildItem -Path $extractDir -Recurse -Include "*.bundle.js","bundle.js","*.js" -File -ErrorAction SilentlyContinue
        $genericTotal = 0
        $xiaoTotal = 0
        foreach ($f in $files) {
            $txt = Get-Content $f.FullName -Raw -Encoding UTF8
            $g = ([regex]::Matches($txt, "esp32:esp32:esp32")).Count
            $x = ([regex]::Matches($txt, "esp32:esp32:XIAO_ESP32C3")).Count
            if ($g -gt 0 -or $x -gt 0) {
                Add-Content $report "------------------------------------------------------------"
                Add-Content $report ("path: " + $f.FullName)
                Add-Content $report ("generic count: " + $g)
                Add-Content $report ("xiao c3 count: " + $x)
            }
            $genericTotal += $g
            $xiaoTotal += $x
        }
        Add-Content $report ""
        Add-Content $report ("TOTAL generic esp32:esp32:esp32: " + $genericTotal)
        Add-Content $report ("TOTAL xiao esp32:esp32:XIAO_ESP32C3: " + $xiaoTotal)
    }
}

$zip = $out + ".zip"
Compress-Archive -Path (Join-Path $out "*") -DestinationPath $zip -Force
Write-Host "Report created:"
Write-Host $zip
