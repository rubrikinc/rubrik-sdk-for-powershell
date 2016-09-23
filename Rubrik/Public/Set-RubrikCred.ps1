#Requires -Version 2
function Set-RubrikCred
{
<#  
            .SYNOPSIS
            Stores a secure credential for scripting rubrik tasks
            .DESCRIPTION
            The Set-RubrikCred cmdlet will store an encrypted password in the modules folder
            .NOTES
            Written by Jason Burrell for community usage
            Twitter: @jasonburrell2
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Set-RubrikCred -user 'admin' -test $true -server [rubrik ip]
#>

  [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Username')]
        [ValidateNotNullorEmpty()]
        [String]$user,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Test connection',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$testconnection
    )

    Process {

# Static variables. Using MyDocuments var for those with redirected folders
$Basepath = [Environment]::GetFolderPath('MyDocuments') + '\WindowsPowerShell\Modules'
$UserPath = $Basepath+'\Rubrik\User.txt'
$PasswordPath = $Basepath+'\Rubrik\Password.txt'

$user | ConvertFrom-SecureString | Out-File $UserPath
$pass = Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File $PasswordPath

 try
        {
            if ($testconnection -eq $true)
            {
               $user = Get-Content $UserPath | ConvertTo-SecureString
               $pass = Get-Content $PasswordPath | ConvertTo-SecureString
               Connect-Rubrik -Server $Server -Username $user -Password $pass 
            }
          }
        catch 
        {
            throw $_
        }

}


}