#requires -Version 2

# Static variables. Using MyDocuments var for those with redirected folders
$Basepath = [Environment]::GetFolderPath('MyDocuments') + '\WindowsPowerShell\Modules'
$InstallPath = $Basepath+'\Rubrik'

# Install the module
$null = New-Item -ItemType Directory -Path $InstallPath
        
# Check the PSModulePath
$pathtest = $env:PSModulePath.Split(';')
if (!($pathtest -contains $Basepath))
{
    #Save the current value in the $p variable.
    $p = [Environment]::GetEnvironmentVariable('PSModulePath','User')
    #Add the new path to the $p variable. Begin with a semi-colon separator.
    $p += ";$Basepath"
    #Add the paths in $p to the PSModulePath value.
    [Environment]::SetEnvironmentVariable('PSModulePath',$p,'User')
}
        
# Import the module
try 
{
    Import-Module -Name Rubrik -ErrorAction Stop
}
catch 
{
    throw 'Error loading the Rubrik module'
}
Write-Host -Object "Rubrik module successfully installed and loaded.`r`nUse Get-Command -Module Rubrik to view all of the available cmdlets"
