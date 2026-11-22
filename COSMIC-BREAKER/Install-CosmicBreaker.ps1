$ErrorActionPreference = 'Stop'

try {
    $sourceFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
    $gameSource = Join-Path $sourceFolder 'brick.html'
    $iconSource = Join-Path $sourceFolder 'CosmicBreaker.ico'

    if (-not (Test-Path -LiteralPath $gameSource -PathType Leaf)) {
        throw 'brick.html is missing. Extract all the ZIP files before running the CMD.'
    }
    if (-not (Test-Path -LiteralPath $iconSource -PathType Leaf)) {
        throw 'CosmicBreaker.ico is missing. Extract all the ZIP files before running the CMD.'
    }

    # Use the installed Microsoft Edge or Google Chrome as the app window runtime.
    $candidates = New-Object 'System.Collections.Generic.List[string]'
    foreach ($base in @(${env:ProgramFiles(x86)}, $env:ProgramFiles, $env:LOCALAPPDATA)) {
        if (-not [string]::IsNullOrWhiteSpace($base)) {
            $candidates.Add((Join-Path $base 'Microsoft\Edge\Application\msedge.exe'))
            $candidates.Add((Join-Path $base 'Google\Chrome\Application\chrome.exe'))
        }
    }
    foreach ($name in @('msedge.exe', 'chrome.exe')) {
        foreach ($hive in @('HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE')) {
            $reg = "Registry::$hive\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$name"
            try {
                $key = Get-Item -LiteralPath $reg -ErrorAction Stop
                $candidate = $key.GetValue('')
                if ($candidate) { $candidates.Add([string] $candidate) }
            } catch { }
        }
    }
    $browser = $null
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $browser = $candidate
            break
        }
    }
    if (-not $browser) {
        throw 'Microsoft Edge or Google Chrome was not found. This shortcut needs one of those browsers (Node.js is NOT required).'
    }

    # Copy the game into a persistent per-user folder. The shortcut works even
    # when the extracted ZIP folder is moved or deleted afterward.
    $installDir = Join-Path $env:LOCALAPPDATA 'Cosmic Breaker'
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
    $gameInstalled = Join-Path $installDir 'brick.html'
    $iconInstalled = Join-Path $installDir 'CosmicBreaker.ico'
    Copy-Item -LiteralPath $gameSource -Destination $gameInstalled -Force
    Copy-Item -LiteralPath $iconSource -Destination $iconInstalled -Force

    $gameUrl = ([System.Uri]::new($gameInstalled)).AbsoluteUri
    $appArgs = '--app="' + $gameUrl + '" --window-size=1180,900'

    $shell = New-Object -ComObject WScript.Shell
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
    if ([string]::IsNullOrWhiteSpace($desktop)) { $desktop = $shell.SpecialFolders.Item('Desktop') }
    if (-not (Test-Path -LiteralPath $desktop)) { throw 'The Windows Desktop folder was not found.' }

    $desktopShortcut = $shell.CreateShortcut((Join-Path $desktop 'Cosmic Breaker.lnk'))
    $desktopShortcut.TargetPath = $browser
    $desktopShortcut.Arguments = $appArgs
    $desktopShortcut.WorkingDirectory = $installDir
    $desktopShortcut.IconLocation = $iconInstalled + ',0'
    $desktopShortcut.Description = 'COSMIC BREAKER - Neon space brick-breaker game'
    $desktopShortcut.WindowStyle = 1
    $desktopShortcut.Save()

    $programs = [Environment]::GetFolderPath([Environment+SpecialFolder]::Programs)
    if (-not [string]::IsNullOrWhiteSpace($programs)) {
        $startShortcut = $shell.CreateShortcut((Join-Path $programs 'Cosmic Breaker.lnk'))
        $startShortcut.TargetPath = $browser
        $startShortcut.Arguments = $appArgs
        $startShortcut.WorkingDirectory = $installDir
        $startShortcut.IconLocation = $iconInstalled + ',0'
        $startShortcut.Description = 'COSMIC BREAKER - Neon space brick-breaker game'
        $startShortcut.WindowStyle = 1
        $startShortcut.Save()
    }

    Write-Host ''
    Write-Host 'Installed successfully!' -ForegroundColor Green
    Write-Host ('Desktop shortcut: ' + (Join-Path $desktop 'Cosmic Breaker.lnk'))
    Write-Host ('Game stored in:   ' + $installDir)
    Write-Host ('App runtime:      ' + $browser)
    Write-Host 'No Node.js, internet, or administrator access was required.'
    exit 0
} catch {
    Write-Host ''
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
