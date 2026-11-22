# THE HOLLOW desktop shortcut installer -- Windows PowerShell 5.1+.
# No Node.js, npm, or administrator rights required.
$ErrorActionPreference = 'Stop'
try {
    $sourceHtml = Join-Path $PSScriptRoot 'THE HOLLOW.html'
    $sourceIcon = Join-Path $PSScriptRoot 'The_Hollow.ico'
    if (-not (Test-Path -LiteralPath $sourceHtml -PathType Leaf)) {
        throw 'THE HOLLOW.html is missing. Extract the entire ZIP and run the CMD from that folder.'
    }
    if (-not (Test-Path -LiteralPath $sourceIcon -PathType Leaf)) {
        throw 'The_Hollow.ico is missing. Extract the entire ZIP and run the CMD from that folder.'
    }

    function Find-SupportedBrowser {
        foreach ($name in @('msedge.exe', 'chrome.exe')) {
            foreach ($base in @('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths')) {
                $keyPath = Join-Path $base $name
                if (Test-Path -LiteralPath $keyPath) {
                    try {
                        $candidate = (Get-Item -LiteralPath $keyPath).GetValue('')
                        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) { return $candidate }
                    } catch { }
                }
            }
            $pf = $env:ProgramFiles
            $pf86 = [Environment]::GetFolderPath('ProgramFilesX86')
            $la = $env:LOCALAPPDATA
            $candidates = if ($name -eq 'msedge.exe') {
                @(
                    (Join-Path $pf 'Microsoft\Edge\Application\msedge.exe'),
                    (Join-Path $pf86 'Microsoft\Edge\Application\msedge.exe'),
                    (Join-Path $la 'Microsoft\Edge\Application\msedge.exe')
                )
            } else {
                @(
                    (Join-Path $pf 'Google\Chrome\Application\chrome.exe'),
                    (Join-Path $pf86 'Google\Chrome\Application\chrome.exe'),
                    (Join-Path $la 'Google\Chrome\Application\chrome.exe')
                )
            }
            foreach ($candidate in $candidates) {
                if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) { return $candidate }
            }
            $cmd = Get-Command $name -ErrorAction SilentlyContinue
            if ($cmd -and $cmd.Source -and (Test-Path -LiteralPath $cmd.Source -PathType Leaf)) { return $cmd.Source }
        }
        return $null
    }

    $browser = Find-SupportedBrowser
    if (-not $browser) {
        throw 'Microsoft Edge or Google Chrome was not found. Install one of these browsers and run this installer again.'
    }

    $appFolder = Join-Path $env:LOCALAPPDATA 'TheHollowDesktop'
    New-Item -ItemType Directory -Path $appFolder -Force | Out-Null
    $installedHtml = Join-Path $appFolder 'THE HOLLOW.html'
    $installedIcon = Join-Path $appFolder 'The_Hollow.ico'
    Copy-Item -LiteralPath $sourceHtml -Destination $installedHtml -Force
    Copy-Item -LiteralPath $sourceIcon -Destination $installedIcon -Force

    # An isolated browser profile keeps game saves and settings between launches.
    $profilePath = Join-Path $appFolder 'BrowserProfile'
    $gameUrl = ([System.Uri]::new([System.IO.Path]::GetFullPath($installedHtml))).AbsoluteUri
    $args = '--user-data-dir="' + $profilePath + '" --app="' + $gameUrl + '"'

    $desktop = [Environment]::GetFolderPath('DesktopDirectory')
    $startMenu = [Environment]::GetFolderPath('Programs')
    if (-not $desktop) { throw 'Windows Desktop folder could not be located.' }
    if (-not $startMenu) { throw 'Windows Start Menu folder could not be located.' }
    $shell = New-Object -ComObject WScript.Shell
    foreach ($folder in @($desktop, $startMenu)) {
        $link = Join-Path $folder 'THE HOLLOW.lnk'
        $shortcut = $shell.CreateShortcut($link)
        $shortcut.TargetPath = $browser
        $shortcut.Arguments = $args
        $shortcut.WorkingDirectory = $appFolder
        $shortcut.IconLocation = $installedIcon + ',0'
        $shortcut.Description = 'THE HOLLOW - psychological horror game'
        $shortcut.WindowStyle = 1
        $shortcut.Save()
    }

    Write-Host ''
    Write-Host 'SUCCESS: THE HOLLOW is installed for this Windows account.' -ForegroundColor Green
    Write-Host 'Your desktop and Start Menu now have a THE HOLLOW shortcut.'
    Write-Host 'The game launches in an app-style window with Edge or Chrome.'
    Write-Host ('Installed files: ' + $appFolder)
    Write-Host 'You may delete the extracted ZIP folder after installation.'
    exit 0
} catch {
    Write-Host ''
    Write-Host ('INSTALLATION FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
