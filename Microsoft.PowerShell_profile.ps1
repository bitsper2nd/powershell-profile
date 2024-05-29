# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "PowerShell version is older than 7.0. Profile will not load"
    Exit
}

# Define user preference files
$env:DOCUMENTS = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$userPreferences = @(
    "$env:DOCUMENTS\PowerShell\User\settings.ps1",
    "$env:DOCUMENTS\PowerShell\User\commands.ps1",
    "$env:DOCUMENTS\PowerShell\User\keybindings.ps1"
)

# Import or create local user preferences
foreach ($module in $userPreferences) {
    if (-not (Test-Path -Path $module)) {
        New-Item -Path $module -ItemType File
        Write-Output "Created new file: $module"
    } else {
        . $module
    }
}
