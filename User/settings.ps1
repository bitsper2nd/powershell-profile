# -- PowerShell Settings --------------------------------------------------------------------------

# Initialize Starship
function Initialize-Starship {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (& starship init powershell)
    }
    elseif ($IsWindows) {
        Write-Host "Starship command not found. Attempting to install via winget..."
        try {
            winget install -e --id Starship.Starship
            Write-Host "Starship installed successfully. Initializing..."
            Invoke-Expression (& starship init powershell)
        }
        catch {
            Write-Error "Failed to install Starship. Error: $_"
        }
    }
}
Initialize-Starship

# Set Colors for PSReadLine
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Green'
    String    = 'DarkCyan'
}

# Prediction View
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
