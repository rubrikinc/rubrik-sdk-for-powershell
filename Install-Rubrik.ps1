#requires -Version 2
$Basepath = "$Home\Documents\WindowsPowerShell\Modules"
$InstallPath = $Basepath+'\Rubrik'

# Installer options
$title = 'Rubrik Module Installer'
$message = "Installation Path: $InstallPath`r`nAre you sure you wish to install or update your Rubrik module?"
$yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Yes'
$no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No', 'No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

# Start installer
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result)
{
    0 
    {
        # Upgrade vs fresh install
        If (Test-Path -Path $InstallPath)
        {
            # Upgrade
            Write-Host -Object 'Found previous installation of Rubrik module. Updating ...'
            $null = Remove-Item -Path $InstallPath -Recurse -Force
            $null = New-Item -ItemType Directory -Path $InstallPath
        }
        Else 
        {
            # Install
            Write-Host -Object 'No previous installation of Rubrik module found. Installing ...'
            $null = New-Item -ItemType Directory -Path $InstallPath
        }

        # Copy over the module folder
        $null = Copy-Item $PSScriptRoot\Rubrik\* $InstallPath -Force -Recurse
        
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
    }


    1 
    {
        Write-Host -Object 'Installation aborted'
    }
}