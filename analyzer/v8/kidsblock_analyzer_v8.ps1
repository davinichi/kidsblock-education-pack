$ErrorActionPreference = 'Continue'
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$base = Join-Path (Get-Location) "kidsblock_analyzer_v8_report_$ts"
New-Item -ItemType Directory -Force -Path $base | Out-Null
$summary = Join-Path $base 'summary.txt'
function Add-Line($s) { Add-Content -Path $summary -Value $s -Encoding UTF8 }
function Safe-Copy($src, $dst) {
    if (Test-Path $src) {
        New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
        Copy-Item $src $dst -Force -ErrorAction SilentlyContinue
    }
}
function Write-Tree($path, $out) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
            Select-Object FullName, Length, LastWriteTime |
            Format-Table -AutoSize | Out-String -Width 240 |
            Set-Content -Path $out -Encoding UTF8
    }
}
function Search-Files($root, $out, $terms) {
    if (!(Test-Path $root)) { return }
    $exts = @('*.js','*.json','*.ts','*.mjs','*.cjs','*.txt','*.cmd','*.bat','*.ps1')
    foreach ($ext in $exts) {
        Get-ChildItem -Path $root -Recurse -Filter $ext -File -ErrorAction SilentlyContinue | ForEach-Object {
            $file = $_.FullName
            $hit = $false
            foreach ($term in $terms) {
                try {
                    if (Select-String -Path $file -Pattern $term -SimpleMatch -Quiet -ErrorAction SilentlyContinue) { $hit = $true }
                } catch {}
            }
            if ($hit) {
                Add-Content -Path $out -Value "`nFILE=$file" -Encoding UTF8
                foreach ($term in $terms) {
                    try {
                        Select-String -Path $file -Pattern $term -SimpleMatch -ErrorAction SilentlyContinue |
                            Select-Object -First 20 |
                            ForEach-Object { Add-Content -Path $out -Value ("  L{0}: {1}" -f $_.LineNumber, $_.Line.Trim()) -Encoding UTF8 }
                    } catch {}
                }
            }
        }
    }
}
Add-Line 'KidsBlock Analyzer v8'
Add-Line ("Generated: " + (Get-Date))
Add-Line ''
Add-Line 'Purpose: collect upload engine files from app.asar.unpacked, especially openblock-link.'
Add-Line ''
$roots = @('C:\KidsBlock Desktop')
$roots += Get-ChildItem 'C:\' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*KidsBlock*' } | ForEach-Object { $_.FullName }
$roots = $roots | Select-Object -Unique
Add-Line 'Install root candidates:'
foreach ($r in $roots) { Add-Line ("  $r exists=" + (Test-Path $r)) }
$terms = @('arduino-cli','--fqbn','fqbn','compile','upload','flash','esp32:esp32','openblock-link','deviceExtensionsCompatible','programMode')
foreach ($root in $roots) {
    if (!(Test-Path $root)) { continue }
    $res = Join-Path $root 'resources'
    $unpacked = Join-Path $res 'app.asar.unpacked'
    Add-Line ''
    Add-Line "ROOT=$root"
    Add-Line ("resources exists=" + (Test-Path $res))
    Add-Line ("app.asar.unpacked exists=" + (Test-Path $unpacked))
    $moduleRoot = Join-Path $unpacked 'node_modules'
    Add-Line ("node_modules exists=" + (Test-Path $moduleRoot))
    $mods = @('openblock-link','openblock-resource')
    foreach ($m in $mods) {
        $mp = Join-Path $moduleRoot $m
        Add-Line ("module $m exists=" + (Test-Path $mp))
        if (Test-Path $mp) {
            $safe = $root.Replace(':','').Replace('\','_').Replace('/','_')
            $dst = Join-Path $base ("collected\$safe\node_modules\$m")
            New-Item -ItemType Directory -Force -Path $dst | Out-Null
            Write-Tree $mp (Join-Path $base ("tree_$m.txt"))
            $searchOut = Join-Path $base ("search_$m.txt")
            Search-Files $mp $searchOut $terms
            $paths = @(
                'package.json','index.js','src\index.js','src\upload\arduino.js','src\upload\index.js','src\upload','upload','lib','dist','script'
            )
            foreach ($p in $paths) {
                $src = Join-Path $mp $p
                if (Test-Path $src) {
                    $target = Join-Path $dst $p
                    if ((Get-Item $src).PSIsContainer) {
                        Copy-Item $src $target -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        Safe-Copy $src $target
                    }
                }
            }
        }
    }
    $scanOut = Join-Path $base 'search_app_asar_unpacked_upload_terms.txt'
    if (Test-Path $unpacked) { Search-Files $unpacked $scanOut @('arduino-cli','--fqbn','fqbn','esp32:esp32:esp32') }
}
# Active external resources summary
$active = Join-Path $env:APPDATA 'KidsBlock\Data\external-resources'
Add-Line ''
Add-Line ("Active external resources: $active exists=" + (Test-Path $active))
if (Test-Path $active) {
    Safe-Copy (Join-Path $active 'devices\device.js') (Join-Path $base 'active_external_resources\devices\device.js')
    $xiaoDev = Join-Path $active 'devices\XIAOESP32C3\XIAOESP32C3\index.js'
    Safe-Copy $xiaoDev (Join-Path $base 'active_external_resources\devices\XIAOESP32C3_index.js')
    $xiaoKit = Join-Path $active 'extensions\arduino\kit\XIAOESP32C3\index.js'
    Safe-Copy $xiaoKit (Join-Path $base 'active_external_resources\kit\XIAOESP32C3_index.js')
}
# zip report
$zip = "$base.zip"
Compress-Archive -Path $base -DestinationPath $zip -Force
Write-Host "Report created: $zip"
