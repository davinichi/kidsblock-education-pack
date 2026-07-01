$ErrorActionPreference = 'Stop'
Write-Host 'EP001 XIAO ESP32C3 v0.8 restore'

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
        $backup = "$($bf.FullName).ep001_xiao_original.bak"
        if (Test-Path $backup) {
            Copy-Item $backup $bf.FullName -Force
            Write-Host "Restored: $($bf.FullName)"
            $restored++
        } else {
            # If no backup exists, just remove EP001 alias marker block.
            $txt = Get-Content -Raw -Encoding UTF8 $bf.FullName
            $begin = '# EP001_XIAO_ESP32C3_ALIAS_BEGIN'
            $end = '# EP001_XIAO_ESP32C3_ALIAS_END'
            if ($txt.Contains($begin)) {
                $pattern = [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + "\r?\n?"
                $txt = [regex]::Replace($txt, $pattern, '', 'Singleline')
                Set-Content -Encoding UTF8 -Path $bf.FullName -Value $txt
                Write-Host "Removed alias block: $($bf.FullName)"
                $restored++
            }
        }
    }
}
Write-Host "Restore operations: $restored"
Write-Host 'Restart KidsBlock after restore.'
