# -- Profile Modules --------------------------------------------------------------------------

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "⚠️ PowerShell version is older than 7.0. Profile will not load"
    Exit
}

# Get the path to the Documents folder
$documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)

# Paths to the settings, commands, and keybindings modules
$settingsPath = "$documentsPath\PowerShell\User\settings.ps1"
$commandsPath = "$documentsPath\PowerShell\User\commands.ps1"
$keybindingsPath = "$documentsPath\PowerShell\User\keybindings.ps1"

# Check if the directories exist, if not, create them
$directoryPath = "$documentsPath\PowerShell\User"
if (-Not (Test-Path -Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath
}

# Check if the files exist, if not, create them
if (-Not (Test-Path -Path $settingsPath)) {
    New-Item -ItemType File -Path $settingsPath
}

if (-Not (Test-Path -Path $commandsPath)) {
    New-Item -ItemType File -Path $commandsPath
}

if (-Not (Test-Path -Path $keybindingsPath)) {
    New-Item -ItemType File -Path $keybindingsPath
}

# Import Settings Module
. $settingsPath

# Deferred module loading
$Deferred = {
    . $commandsPath
    . $keybindingsPath
}

# Setup global state
$GlobalState = [psmoduleinfo]::new($false)
$GlobalState.SessionState = $ExecutionContext.SessionState

# Create and configure the runspace
$Runspace = [runspacefactory]::CreateRunspace($Host)
$Runspace.Open()
$Runspace.SessionStateProxy.PSVariable.Set('GlobalState', $GlobalState)

# Reflection to get private properties and fields
$Private = [Reflection.BindingFlags]'Instance, NonPublic'
$ContextField = [Management.Automation.EngineIntrinsics].GetField('_context', $Private)
$Context = $ContextField.GetValue($ExecutionContext)

# Get or initialize the Custom and Native ArgumentCompleters
$ContextCACProperty = $Context.GetType().GetProperty('CustomArgumentCompleters', $Private)
$ContextNACProperty = $Context.GetType().GetProperty('NativeArgumentCompleters', $Private)
$CAC = $ContextCACProperty.GetValue($Context)
$NAC = $ContextNACProperty.GetValue($Context)

if ($null -eq $CAC) {
    $CAC = [Collections.Generic.Dictionary[string, scriptblock]]::new()
    $ContextCACProperty.SetValue($Context, $CAC)
}

if ($null -eq $NAC) {
    $NAC = [Collections.Generic.Dictionary[string, scriptblock]]::new()
    $ContextNACProperty.SetValue($Context, $NAC)
}

# Setup runspace to use global ArgumentCompleters
$RSEngineField = $Runspace.GetType().GetField('_engine', $Private)
$RSEngine = $RSEngineField.GetValue($Runspace)
$EngineContextField = $RSEngine.GetType().GetFields($Private) | Where-Object { $_.FieldType.Name -eq 'ExecutionContext' }
$RSContext = $EngineContextField.GetValue($RSEngine)

$ContextCACProperty.SetValue($RSContext, $CAC)
$ContextNACProperty.SetValue($RSContext, $NAC)

# Wrapper script to run deferred module loading
$Wrapper = {
    Start-Sleep -Milliseconds 200
    . $GlobalState {
        . $Deferred
        Remove-Variable Deferred
    }
}

# Run the wrapper script asynchronously
$Powershell = [powershell]::Create($Runspace)
$null = $Powershell.AddScript($Wrapper.ToString()).BeginInvoke()
