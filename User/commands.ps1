# Utility Functions
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Editor Configuration
$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists pvim) { 'pvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }
          else { 'notepad' }
Set-Alias -Name vim -Value $EDITOR

# Quick Access to Editing the Profile
function Edit-Profile { vim $PROFILE }
function Reload-Profile {
    & $profile
}

# Create file
function touch($file) { "" | Out-File $file -Encoding ASCII }
function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

# Network Utilities
function Get-IP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# System Utilities
function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10, [switch]$f = $false)
  Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
    Clear-DnsClientCache
    Write-Host "DNS has been flushed"
}

function Debloat-Windows { powershell "irm christitus.com/win | iex" }
function Activate-Windows { powershell "irm massgrave.dev/get | iex" }

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
    Update-Settings
    Update-Commands
    Update-Keybindings
}

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
Update-PowerShell
