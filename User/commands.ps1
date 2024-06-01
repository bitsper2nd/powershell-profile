# -- PowerShell Commands --------------------------------------------------------------------------

# Check for Commands Update
function Update-Commands {
    try {
        $commandsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/commands.ps1"
        $commandsPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\User\commands.ps1"
        $tempCommandsPath = Join-Path -Path $env:TEMP -ChildPath "commands.ps1"

        # Check if the old commands file exists
        if (Test-Path $commandsPath) {
            $oldCommandsHash = Get-FileHash $commandsPath
        } else {
            $oldCommandsHash = $null
        }

        Invoke-RestMethod $commandsUpdateUrl -OutFile $tempCommandsPath
        $newCommandsHash = Get-FileHash $tempCommandsPath

        if ($oldCommandsHash -eq $null -or $newCommandsHash.Hash -ne $oldCommandsHash.Hash) {
            Copy-Item -Path $tempCommandsPath -Destination $commandsPath -Force
            Write-Host "Commands file has been updated." -ForegroundColor Magenta
        } else {
            Write-Host "Commands file is already up-to-date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for commands update: $_"
    } finally {
        Remove-Item $tempCommandsPath -ErrorAction SilentlyContinue
    }
}

# Check for Keybindings Update
function Update-Keybindings {
    try {
        $keybindingsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/keybindings.ps1"
        $keybindingsPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\User\keybindings.ps1"
        $tempKeybindingsPath = Join-Path -Path $env:TEMP -ChildPath "keybindings.ps1"

        # Check if the old keybindings file exists
        if (Test-Path $keybindingsPath) {
            $oldKeybindingsHash = Get-FileHash $keybindingsPath
        } else {
            $oldKeybindingsHash = $null
        }

        Invoke-RestMethod $keybindingsUpdateUrl -OutFile $tempKeybindingsPath
        $newKeybindingsHash = Get-FileHash $tempKeybindingsPath

        if ($oldKeybindingsHash -eq $null -or $newKeybindingsHash.Hash -ne $oldKeybindingsHash.Hash) {
            Copy-Item -Path $tempKeybindingsPath -Destination $keybindingsPath -Force
            Write-Host "Keybindings file has been updated." -ForegroundColor Magenta
        } else {
            Write-Host "Keybindings file is already up-to-date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for keybindings update: $_"
    } finally {
        Remove-Item $tempKeybindingsPath -ErrorAction SilentlyContinue
    }
}

# Check for Settings Update
function Update-Settings {
    try {
        $settingsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/settings.ps1"
        $settingsPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\User\settings.ps1"
        $tempSettingsPath = Join-Path -Path $env:TEMP -ChildPath "settings.ps1"

        # Check if the old settings file exists
        if (Test-Path $settingsPath) {
            $oldSettingsHash = Get-FileHash $settingsPath
        } else {
            $oldSettingsHash = $null
        }

        Invoke-RestMethod $settingsUpdateUrl -OutFile $tempSettingsPath
        $newSettingsHash = Get-FileHash $tempSettingsPath

        if ($oldSettingsHash -eq $null -or $newSettingsHash.Hash -ne $oldSettingsHash.Hash) {
            Copy-Item -Path $tempSettingsPath -Destination $settingsPath -Force
            Write-Host "Settings file has been updated." -ForegroundColor Magenta
        } else {
            Write-Host "Settings file is already up-to-date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for Settings update: $_"
    } finally {
        Remove-Item $tempSettingsPath -ErrorAction SilentlyContinue
    }
}

# Check for Preferences Update
function Update-Preferences {
    $confirmation = Read-Host "💭 Do you want to update preferences? (Y/N)"
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        try {
            Update-Settings
            Update-Commands
            Update-Keybindings
            Write-Host "Preferences update succeeded." -ForegroundColor Green
        } catch {
            Write-Error "Unable to update preferences: $_"
            Write-Host "Preferences update failed." -ForegroundColor Red
        }
    }
}

# Check for PowerShell Update
function Update-PowerShell {
    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan

        $currentVersion = [Version]$PSVersionTable.PSVersion
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = [Version]$latestReleaseInfo.tag_name.TrimStart('v')

        if ($currentVersion -lt $latestVersion) {
            Write-Host "Updating PowerShell to version $latestVersion..." -ForegroundColor Yellow
            winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes." -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}
