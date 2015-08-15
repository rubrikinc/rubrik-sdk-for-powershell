#requires -Version 1
$InstallPath = "$Home\Documents\WindowsPowerShell\Modules\Rubrik"

$title = 'Rubrik Module Installer'
$message = "Installation Path: $InstallPath`r`nAre you sure you wish to install or update your Rubrik module?"
$yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Yes'

$no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No', 'No'

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result)
{
    0 
    {
        If (Test-Path -Path $InstallPath)
        {
            Write-Host -Object 'Found previous installation of Rubrik module. Updating ...'
            Remove-Item -Path $InstallPath -Recurse -Force
            New-Item -ItemType Directory -Path $InstallPath
        }
        Else 
        {
            Write-Host -Object 'No previous installation of Rubrik module found. Installing ...'
            New-Item -ItemType Directory -Path $InstallPath
        }

        Copy-Item $PSScriptRoot\* $InstallPath -Force -Recurse
    }


    1 
    {
        Write-Host -Object 'Installation aborted'
    }
}