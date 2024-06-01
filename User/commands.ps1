# -- PowerShell Commands --------------------------------------------------------------------------

function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { Write-Host "$command does not exist"; RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
}

# -- System --------------------------------------------------------------------------

function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Aliases for reboot and poweroff
function Reboot-System {
    Restart-Computer -Force
    Set-Alias reboot Reboot-System
}
function Poweroff-System {
    Stop-Computer -Force
    Set-Alias poweroff Poweroff-System
}

# -- Updater --------------------------------------------------------------------------

# Check for Commands Update
function Update-Commands {
    try {
        $commandsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/commands.ps1"
        $commandsPath = "$env:DOCUMENTS\PowerShell\User\commands.ps1"
        $oldCommandsHash = Get-FileHash $commandsPath
        Invoke-RestMethod $commandsUpdateUrl -OutFile "$env:temp\commands.ps1"
        $newCommandsHash = Get-FileHash "$env:temp\commands.ps1"
        if ($newCommandsHash.Hash -ne $oldCommandsHash.Hash) {
            Copy-Item -Path "$env:temp\commands.ps1" -Destination $commandsPath -Force
            Write-Host "Commands file has been updated." -ForegroundColor Magenta
        }
    } catch {
        Write-Error "Unable to check for commands update"
    } finally {
        Remove-Item "$env:temp\commands.ps1" -ErrorAction SilentlyContinue
    }
}

# Check for Keybindings Update
function Update-Keybindings {
    try {
            $keybindingsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/keybindings.ps1"
                $keybindingsPath = "$env:DOCUMENTS\PowerShell\User\keybindings.ps1"
                $oldKeybindingsHash = Get-FileHash $keybindingsPath
                Invoke-RestMethod $keybindingsUpdateUrl -OutFile "$env:temp\keybindings.ps1"
                $newKeybindingsHash = Get-FileHash "$env:temp\keybindings.ps1"
                if ($newKeybindingsHash.Hash -ne $oldKeybindingsHash.Hash) {
                    Copy-Item -Path "$env:temp\keybindings.ps1" -Destination $keybindingsPath -Force
                    Write-Host "keybindings file has been updated." -ForegroundColor Magenta
                }
            } catch {
                Write-Error "Unable to check for keybindings update"
            } finally {
                Remove-Item "$env:temp\keybindings.ps1" -ErrorAction SilentlyContinue
            }
        }

# Check for Settings Update
function Update-Settings {
    try {
        $settingsUpdateUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/settings.ps1"
        $settingsPath = "$env:DOCUMENTS\PowerShell\User\settings.ps1"
        $oldSettingsHash = Get-FileHash $SettingsPath
        Invoke-RestMethod $settingsUpdateUrl -OutFile "$env:temp\settings.ps1"
        $newSettingsHash = Get-FileHash "$env:temp\settings.ps1"
        if ($newSettingsHash.Hash -ne $oldSettingsHash.Hash) {
            Copy-Item -Path "$env:temp\settings.ps1" -Destination $SettingsPath -Force
            Write-Host "Settings file has been updated." -ForegroundColor Magenta
        }
    } catch {
        Write-Error "Unable to check for Settings update"
    } finally {
        Remove-Item "$env:temp\settings.ps1" -ErrorAction SilentlyContinue
    }
}

function Update-Preferences {
    $confirmation = Read-Host "💭 Do you want to update preferences? (Y/N)"
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Update-Settings
    Update-Commands
    Update-Keybindings
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
