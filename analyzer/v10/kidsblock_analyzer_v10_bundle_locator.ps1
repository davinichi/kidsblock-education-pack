$ErrorActionPreference = "Continue"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path (Get-Location) ("kidsblock_analyzer_v10_bundle_report_" + $ts)
New-Item -ItemType Directory -Path $out -Force | Out-Null

$report = Join-Path $out "report.txt"
Add-Content $report "KidsBlock Analyzer v10 - bundle locator"
Add-Content $report ("Generated: " + (Get-Date))
Add-Content $report ""

$candidates = @()
$candidates += "C:\KidsBlock Desktop"
$candidates += (Join-Path $env:APPDATA "KidsBlock")
$candidates += (Join-Path $env:LOCALAPPDATA "Programs")
$candidates += (Join-Path $env:LOCALAPPDATA "KidsBlock")
$candidates += (Get-Location).Path

Add-Content $report "Search roots:"
foreach ($c in $candidates) {
    Add-Content $report ("  " + $c + " exists=" + (Test-Path $c))
}
Add-Content $report ""

$found = @()
foreach ($root in $candidates) {
    if (Test-Path $root) {
        try {
            $files = Get-ChildItem -Path $root -Recurse -Filter "2.bundle.js" -File -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                $found += $f.FullName
            }
        } catch {
            Add-Content $report ("Search error: " + $root + " : " + $_.Exception.Message)
        }
    }
}

$found = $found | Sort-Object -Unique

Add-Content $report ("Found 2.bundle.js count: " + $found.Count)
Add-Content $report ""

foreach ($path in $found) {
    Add-Content $report "------------------------------------------------------------"
    Add-Content $report ("PATH: " + $path)
    try {
        $txt = Get-Content $path -Raw -Encoding UTF8
        $hasEsp32 = $txt.Contains("esp32:esp32:esp32")
        $hasXiao = $txt.Contains("esp32:esp32:XIAO_ESP32C3")
        Add-Content $report ("contains esp32:esp32:esp32: " + $hasEsp32)
        Add-Content $report ("contains esp32:esp32:XIAO_ESP32C3: " + $hasXiao)

        $matches = [regex]::Matches($txt, "fqbn\s*:\s*['""][^'""]+['""]")
        Add-Content $report ("fqbn line count: " + $matches.Count)
        $i = 0
        foreach ($m in $matches) {
            if ($i -lt 20) {
                Add-Content $report ("  " + $m.Value)
            }
            $i++
        }

        if ($hasEsp32) {
            $snippetFile = Join-Path $out ("snippet_" + ([IO.Path]::GetFileNameWithoutExtension($path)) + "_" + ([Math]::Abs($path.GetHashCode())) + ".txt")
            $idx = $txt.IndexOf("esp32:esp32:esp32")
            $start = [Math]::Max(0, $idx - 600)
            $len = [Math]::Min(1600, $txt.Length - $start)
            $txt.Substring($start, $len) | Set-Content $snippetFile -Encoding UTF8
        }
    } catch {
        Add-Content $report ("Read error: " + $_.Exception.Message)
    }
}

# Also check if app.asar exists. It may contain the bundle internally.
Add-Content $report ""
Add-Content $report "app.asar candidates:"
$asarCandidates = @(
    "C:\KidsBlock Desktop\resources\app.asar",
    (Join-Path $env:APPDATA "KidsBlock\app.asar")
)
foreach ($a in $asarCandidates) {
    Add-Content $report ("  " + $a + " exists=" + (Test-Path $a))
}

$zip = $out + ".zip"
Compress-Archive -Path (Join-Path $out "*") -DestinationPath $zip -Force
Write-Host "Report created:"
Write-Host $zip
