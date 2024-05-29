# -- PowerShell Commands --------------------------------------------------------------------------

# Editor Aliases
Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { Write-Host "$command does not exist"; RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
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
Set-Alias subl sublime_text

# Quick Access to Editing the Profile
function Edit-Profile { vim $PROFILE }
function Reload-Profile {
    & $profile
}

# -- File Aliases --------------------------------------------------------------------------

# Create file
function touch($file) { "" | Out-File $file -Encoding ASCII }
function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

function unzip {
    param (
        [Parameter(Mandatory = $true)]
        $File
    )

    $DestinationPath = Split-Path -Path $file
    if ([string]::IsNullOrEmpty($DestinationPath)) {

        $DestinationPath=$PWD
    }

    if (Test-Path ($File)) {

        Write-Output "Extracting $File to $DestinationPath"
        Expand-Archive -Path $File -DestinationPath $DestinationPath

    }else {
        $FileName=Split-Path $File -leaf
        Write-Output "File $FileName does not exist"
    }

}

function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function expl { explorer . }

function grep {
    param (
        [string]$regex,
        [string]$dir
    )
    process {
        if ($dir) {
            Get-ChildItem -Path $dir -Recurse -File | Select-String -Pattern $regex
        } else {     # Use if piped input is provided
            $input | Select-String -Pattern $regex
        }
    }
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

function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
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

# SSH key
function ssh-copy-key {
    param(
        [parameter(Position=0)]
        [string]$user,

        [parameter(Position=1)]
        [string]$ip
    )
    $pubKeyPath = "~\.ssh\id_ed25519.pub"
    $sshCommand = "cat $pubKeyPath | ssh $user@$ip 'cat >> ~/.ssh/authorized_keys'"
    Invoke-Expression $sshCommand
}

# -- Git Aliases --------------------------------------------------------------------------

function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gp { git push }

function gcl { git clone "$args" }

function gcom {
    git add .
    git commit -m "$args"
}
function lazyg {
    git add .
    git commit -m "$args"
    git push
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
    Update-Settings
    Update-Commands
    Update-Keybindings
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
Update-PowerShell
