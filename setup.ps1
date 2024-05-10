# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}

# Profile creation or update
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of PowerShell & Create Profile directories if they do not exist.
        $profilePath = ""
        if ($PSVersionTable.PSEdition -eq "Core") { 
            $profilePath = "$env:userprofile\Documents\Powershell"
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory"
        }

        Invoke-RestMethod https://github.com/bitsper2nd/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
        Write-Host "If you want to add any persistent components, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
        Invoke-RestMethod https://github.com/bitsper2nd/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
        Write-Host "Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to backup and update the profile. Error: $_"
    }
}

# Winget Install
try {
    winget install -e --id "Starship.Starship" && "ajeetdsouza.zoxide" && "gerardog.gsudo" && "lsd-rs.lsd" && "BurntSushi.ripgrep.MSVC" && "Git.MinGit" && "sharkdp.bat" && "sharkdp.fd" && "chmln.sd" && "tldr-pages.tlrc"
}
catch {
    Write-Error "Failed to install Command Line tools. Error: $_"
}

# Final check and message to the user
if ((Test-Path -Path $PROFILE) -and (winget list --id "Starship.Starship" && "ajeetdsouza.zoxide" && "gerardog.gsudo" && "lsd-rs.lsd" && "BurntSushi.ripgrep.MSVC" && "Git.MinGit" && "sharkdp.bat" && "sharkdp.fd" && "chmln.sd" && "tldr-pages.tlrc")) {
    Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
} else {
    Write-Warning "Setup completed with errors. Please check the error messages above."
}
