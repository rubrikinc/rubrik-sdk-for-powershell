function GetRubrikInstall 
{
  # Returns the known installation locations for the Rubrik Module
  return Get-Module -ListAvailable -Name Rubrik -ErrorAction SilentlyContinue | Select-Object -Property Name, Version, ModuleBase
}

function GetPSModulePath 
{
  # Returns all available PowerShell Module paths  
  return $env:PSModulePath.Split(';')
}

function InstallMenu 
{
  # Creates a menu of available install or upgrade locations for the module
  Param(
    [Array]$InstallPathList,
    [ValidateSet('installation','upgrade or delete')]
    [String]$InstallAction
  )
  $i = 1
  foreach ($Location in $InstallPathList)
  {
    Write-Host -Object "$i`: $Location"
    $i++
  }

  While ($true) 
  {
    [int]$LocationSelection = Read-Host -Prompt "`nPlease select an $InstallAction path"
    if ($LocationSelection -lt 1 -or $LocationSelection -gt $InstallPathList.Length)
    {
      Write-Host -Object "Invalid selection. Please enter a number in range [1-$($InstallPathList.Length)]"
    } 
    else
    {
      break
    }
  }
  
  return $InstallPathList[($LocationSelection - 1)]
}

function RemoveModuleContent 
{
  # Attempts to remove contents from an existing installation
  try 
  {
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop -Confirm:$true
  }
  catch 
  {
    throw "$($_.ErrorDetails)"
  }
}

function CreateModuleContent
{
  # Attempts to create a new folder and copy over the Rubrik Module contents
  try
  {
    $null = New-Item -ItemType Directory -Path $InstallPath -Force -ErrorAction Stop
    $null = Copy-Item $PSScriptRoot\Rubrik\* $InstallPath -Force -Recurse -ErrorAction Stop
    $null = Test-Path -Path $InstallPath -ErrorAction Stop
    
    Write-Host -Object "`nInstallation successful."
  }
  catch 
  {
    throw $_
  }
}

function ReportRubrikModule
{
  # Removes the Rubrik Module from the active session and displays a list of all current install locations
  Remove-Module -Name Rubrik -ErrorAction SilentlyContinue
  GetRubrikInstall
}

### Code
Clear-Host

[Array]$RubrikInstall = GetRubrikInstall
if ($RubrikInstall.Length -gt 0)
{
  Write-Warning -Message 'Found an existing Rubrik Module installed.' -WarningAction Continue
  $RubrikInstall += @{
    Name       = 'Delete All'
    Version    = 0.0.0.0
    ModuleBase = 'DELETE all listed installations of the Rubrik Module'
  }
  $InstallPath = InstallMenu -InstallPathList $RubrikInstall.ModuleBase -InstallAction 'upgrade or delete'
  
  if ($InstallPath.Split(' ')[0] -eq 'DELETE')
  {
    foreach ($Location in ([Array]$RubrikInstall = GetRubrikInstall).ModuleBase)
    {
      $InstallPath = $Location
      RemoveModuleContent      
    }
    break
  }
  else
  {
    RemoveModuleContent
    CreateModuleContent
  }
}
else
{
  Write-Warning -Message 'Could not find an existing Rubrik Module installation.' -WarningAction Continue
  $InstallPath = InstallMenu -InstallPathList (GetPSModulePath) -InstallAction installation
  $InstallPath = $InstallPath + '\Rubrik\'
  CreateModuleContent
}

Write-Host -Object "`nRubrik Module installation location(s):"
ReportRubrikModule | Format-Table