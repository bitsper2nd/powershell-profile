# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "⚠️ Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "❌ Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}

# Install PowerShell Core
$confirmation = Read-Host "💭 Do you want to install PowerShell Core? (Y/N)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    try {
        winget install --id=Microsoft.PowerShell
        Write-Host "🟢 PowerShell Core installation initiated." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install PowerShell Core. Error: $_"
    }
} else {
    Write-Host "⛔ PowerShell Core installation aborted." -ForegroundColor Yellow
}

# Prompt user for confirmation
$confirmation = Read-Host "💭 Do you want to create or update your PowerShell profile, settings, commands, and keybindings? (Y/N)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    try {
        # Profile creation or update
        if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
            # Detect Version of PowerShell & Create Profile directories if they do not exist.
            $profilePath = if ($PSVersionTable.PSEdition -eq "Core") {
                "$env:userprofile\Documents\Powershell"
            } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
                "$env:userprofile\Documents\WindowsPowerShell"
            }

            if (!(Test-Path -Path $profilePath)) {
                New-Item -Path $profilePath -ItemType "directory"
            }

            Invoke-RestMethod https://github.com/bitsper2nd/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
            Write-Host "✅ The profile @ [$PROFILE] has been created."
            Write-Host "💡 If you want to add any persistent components, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
        } else {
            Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
            Invoke-RestMethod https://github.com/ShadowElixir/better-powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
            Write-Host "✅ The profile @ [$PROFILE] has been updated and old profile backed up."
            Write-Host "💡 Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
        }

        # Create or update settings.ps1, commands.ps1, and keybindings.ps1
        $preferences = @(
            @{ FileType = "Settings"; FileUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/settings.ps1"; FilePath = "$profilePath\User\settings.ps1" },
            @{ FileType = "Commands"; FileUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/commands.ps1"; FilePath = "$profilePath\User\commands.ps1" },
            @{ FileType = "Keybindings"; FileUrl = "https://github.com/bitsper2nd/powershell-profile/raw/dev/User/keybindings.ps1"; FilePath = "$profilePath\User\keybindings.ps1" }
        )

        foreach ($preference in $preferences) {
            try {
                $oldHash = if (Test-Path -Path $preference.FilePath) { Get-FileHash $preference.FilePath } else { $null }
                Invoke-RestMethod $preference.FileUrl -OutFile "$env:temp\$($preference.FileType).ps1"
                $newHash = Get-FileHash "$env:temp\$($preference.FileType).ps1"

                if ($null -eq $oldHash -or $newHash.Hash -ne $oldHash.Hash) {
                    Copy-Item -Path "$env:temp\$($preference.FileType).ps1" -Destination $preference.FilePath -Force
                    Write-Host "✅ $($preference.FileType) file has been updated." -ForegroundColor Magenta
                } else {
                    Write-Host "✅ $($preference.FileType) file is already up to date." -ForegroundColor Green
                }
            } catch {
                Write-Error "❌ Unable to check for $($preference.FileType) update"
            } finally {
                Remove-Item "$env:temp\$($preference.FileType).ps1" -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Error "❌ Failed to create or update the profile or preferences. Error: $_"
    }
} else {
    Write-Host "⛔ Operation aborted by the user." -ForegroundColor Yellow
}

# Install Command Line tools
$confirmation = Read-Host "💭 Do you want to install Command Line tools? (Y/N)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    try {
        winget install --id=Starship.Starship &&
        winget install --id=ajeetdsouza.zoxide &&
        winget install --id=gerardog.gsudo &&
        winget install --id=eza-community.eza &&
        winget install --id=BurntSushi.ripgrep.GNU &&
        winget install --id=Git.MinGit &&
        winget install --id=sharkdp.bat &&
        winget install --id=sharkdp.fd &&
        winget install --id=chmln.sd &&
        winget install --id=tldr-pages.tlrc
        Write-Host "🟢 Command Line tools installation initiated." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install Command Line tools. Error: $_"
    }
} else {
    Write-Host "⛔ Command Line tools installation aborted." -ForegroundColor Yellow
}
