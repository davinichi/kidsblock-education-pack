$ErrorActionPreference = 'Stop'
Write-Host 'EP001 XIAO ESP32C3 v0.8 checker'

$roaming = [Environment]::GetFolderPath('ApplicationData')
$target = Join-Path $roaming 'KidsBlock\Data\external-resources'
$deviceJs = Join-Path $target 'devices\device.js'
$deviceIndex = Join-Path $target 'devices\XIAOESP32C3\XIAOESP32C3\index.js'

Write-Host "Active external-resources: $target"
Write-Host "device.js exists: $(Test-Path $deviceJs)"
if (Test-Path $deviceJs) {
    $d = Get-Content -Raw -Encoding UTF8 $deviceJs
    Write-Host "device.js has XIAOESP32C3_arduinoEsp32: $($d.Contains('XIAOESP32C3_arduinoEsp32'))"
}
Write-Host "device index exists: $(Test-Path $deviceIndex)"

$candidates = @(
    'C:\KidsBlock Desktop',
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock Desktop'),
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock')
)
$boardsFiles = @()
foreach ($root in $candidates) {
    $p = Join-Path $root 'resources\tools\Arduino\packages\esp32\hardware\esp32'
    if (Test-Path $p) { $boardsFiles += Get-ChildItem -Path $p -Recurse -Filter 'boards.txt' -File }
}
$boardsFiles = $boardsFiles | Sort-Object FullName -Unique
Write-Host "boards.txt count: $($boardsFiles.Count)"
foreach ($bf in $boardsFiles) {
    $txt = Get-Content -Raw -Encoding UTF8 $bf.FullName
    Write-Host '---'
    Write-Host $bf.FullName
    Write-Host "has XIAO_ESP32C3 section: $($txt -match '(?m)^XIAO_ESP32C3\.')"
    Write-Host "has EP001 alias: $($txt.Contains('# EP001_XIAO_ESP32C3_ALIAS_BEGIN'))"
    if ($txt.Contains('# EP001_XIAO_ESP32C3_ALIAS_BEGIN')) {
        ($txt -split "`r?`n") | Where-Object { $_ -match '^esp32\.(build\.mcu|build\.variant|build\.tarch|upload\.tool|name)=' } | ForEach-Object { Write-Host $_ }
    }
}
