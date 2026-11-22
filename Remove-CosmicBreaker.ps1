$ErrorActionPreference = 'Stop'
try {
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
    $programs = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
    foreach ($folder in @($desktop, $programs)) {
        if ($folder) {
            $shortcut = Join-Path $folder 'Cosmic Breaker.lnk'
            if (Test-Path -LiteralPath $shortcut) {
                Remove-Item -LiteralPath $shortcut -Force
            }
        }
    }
    $installDir = Join-Path $env:LOCALAPPDATA 'Cosmic Breaker'
    foreach ($name in @('brick.html','CosmicBreaker.ico')) {
        $file = Join-Path $installDir $name
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
    }
    if ((Test-Path -LiteralPath $installDir) -and -not (Get-ChildItem -LiteralPath $installDir -Force | Select-Object -First 1)) {
        Remove-Item -LiteralPath $installDir -Force
    }
    Write-Host 'Removed shortcuts and the installed game files.' -ForegroundColor Green
    Write-Host 'Browser high-score data may remain in your browser profile.'
    exit 0
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
