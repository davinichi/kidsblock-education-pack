$ErrorActionPreference = "Continue"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path (Get-Location) ("kidsblock_analyzer_v12_rc2_report_" + $ts)
New-Item -ItemType Directory -Path $out -Force | Out-Null
$report = Join-Path $out "report.txt"

$appAsar = "C:\KidsBlock Desktop\resources\app.asar"

Add-Content $report "KidsBlock Analyzer v12 - RC2 verification"
Add-Content $report ("Generated: " + (Get-Date))
Add-Content $report ("app.asar exists: " + (Test-Path $appAsar))

try {
    $npxVersion = & npx --version 2>$null
    Add-Content $report ("npx: " + $npxVersion)
} catch {
    Add-Content $report "npx: not found"
}

if (Test-Path $appAsar) {
    $work = Join-Path $env:TEMP ("kb_analyzer_v12_" + $ts)
    $extractDir = Join-Path $work "app"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    & npx asar extract $appAsar $extractDir
    Add-Content $report ("asar extract exit code: " + $LASTEXITCODE)

    if ($LASTEXITCODE -eq 0) {
        $files = Get-ChildItem -Path $extractDir -Recurse -Include "*.bundle.js","bundle.js" -File -ErrorAction SilentlyContinue
        Add-Content $report ("bundle file count: " + $files.Count)
        foreach ($f in $files) {
            $txt = Get-Content $f.FullName -Raw -Encoding UTF8
            if ($txt.Contains("esp32:esp32:esp32") -or $txt.Contains("esp32:esp32:XIAO_ESP32C3")) {
                Add-Content $report "------------------------------------------------------------"
                Add-Content $report ("path: " + $f.FullName)
                Add-Content $report ("contains generic esp32 FQBN: " + $txt.Contains("esp32:esp32:esp32"))
                Add-Content $report ("contains XIAO C3 FQBN: " + $txt.Contains("esp32:esp32:XIAO_ESP32C3"))
            }
        }
    }
}

$zip = $out + ".zip"
Compress-Archive -Path (Join-Path $out "*") -DestinationPath $zip -Force
Write-Host "Report created:"
Write-Host $zip
