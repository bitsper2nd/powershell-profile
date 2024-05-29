# -- PowerShell Settings --------------------------------------------------------------------------

# Initialize Starship prompt
& starship init powershell | Invoke-Expression

# Set Colors for PSReadLine
Set-PSReadLineOption -Colors @{
    Command   = 'Yellow'
    Parameter = 'Green'
    String    = 'DarkCyan'
}

# Prediction View
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
