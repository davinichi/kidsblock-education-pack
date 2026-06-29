$ErrorActionPreference = 'Stop'
Write-Host 'EP001 XIAO ESP32C3 v0.8 SAFE restore'
Write-Host 'This restores the bundled ESP32 boards.txt from the v0.8 backup if present.'

function Write-Utf8NoBom($path, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $text, $enc)
}

$candidates = @(
    'C:\KidsBlock Desktop',
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock Desktop'),
    (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Programs\KidsBlock')
)

$restored = 0
foreach ($root in $candidates) {
    $p = Join-Path $root 'resources\tools\Arduino\packages\esp32\hardware\esp32'
    if (!(Test-Path $p)) { continue }
    foreach ($bf in Get-ChildItem -Path $p -Recurse -Filter 'boards.txt' -File) {
        $boardsPath = $bf.FullName
        $backup = "$boardsPath.ep001_xiao_original.bak"
        if (Test-Path $backup) {
            Copy-Item $backup $boardsPath -Force
            Write-Host "Restored from backup: $boardsPath"
            $restored++
            continue
        }

        $txt = [System.IO.File]::ReadAllText($boardsPath)
        $begin = '# EP001_XIAO_ESP32C3_ALIAS_BEGIN'
        $end = '# EP001_XIAO_ESP32C3_ALIAS_END'
        if ($txt.Contains($begin)) {
            $pattern = [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + "\r?\n?"
            $txt = [regex]::Replace($txt, $pattern, '', 'Singleline')
            Write-Utf8NoBom $boardsPath $txt
            Write-Host "Removed EP001 alias block: $boardsPath"
            $restored++
        }
    }
}

Write-Host "Restore operations: $restored"
Write-Host 'Please restart KidsBlock before compiling again.'
