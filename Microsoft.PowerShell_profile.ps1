# Define user preference files
$env:DOCUMENTS = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$localUserPreferences = @(
    "$env:DOCUMENTS\PowerShell\User\commands.ps1",
    "$env:DOCUMENTS\PowerShell\User\keybindings.ps1",
    "$env:DOCUMENTS\PowerShell\User\settings.ps1"
)

# Import or create local user preferences
foreach ($module in $localUserPreferences) {
    if (-not (Test-Path -Path $module)) {
        New-Item -Path $module -ItemType File
        Write-Output "Created new file: $module"
    } else {
        . $module
    }
}
