$ErrorActionPreference = 'Stop'
try {
    $desktop = [Environment]::GetFolderPath('DesktopDirectory')
    $startMenu = [Environment]::GetFolderPath('Programs')
    foreach ($folder in @($desktop, $startMenu)) {
        $link = Join-Path $folder 'THE HOLLOW.lnk'
        if (Test-Path -LiteralPath $link) { Remove-Item -LiteralPath $link -Force }
    }
    $folder = Join-Path $env:LOCALAPPDATA 'TheHollowDesktop'
    foreach ($file in @('THE HOLLOW.html','The_Hollow.ico')) {
        $p = Join-Path $folder $file
        if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force }
    }
    Write-Host 'Desktop and Start Menu shortcuts removed.' -ForegroundColor Green
    Write-Host 'The BrowserProfile folder was retained to preserve saved game progress.'
    Write-Host ('To fully delete saves later, remove: ' + $folder)
    exit 0
} catch {
    Write-Host ('Uninstall failed: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
