#Requires -Version 3
function Get-RubrikDebugInfo
{
  <#  
    .SYNOPSIS
    Displays information about the Rubrik module and the PowerShell 
        
    .DESCRIPTION
    The Get-RubrikDebugInfo cmdlet will retrieve the version of code that is actively running on the system. It will gather essential information that can be used for quickly troubleshooting issues
        
    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: JaapBrasser
        
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdebuginfo
        
    .EXAMPLE
    Get-RubrikDebugInfo

    This will return information about the PowerShell version, the PowerShell client or console, and both the Rubrik cluster and Rubrik PowerShell module version numbers
  #>

  [CmdletBinding()]
  Param(
  )

  Process {
    # Initiate Hash
    $HashProps = [ordered]@{}

    # Add PSVersionTable
    $PSVersionTable.Keys | ForEach-Object {
        $HashProps.$_ = $PSVersionTable.$_
    }

    # Add Console Host information
    $HashProps.HostConsoleName = $host.Name
    $HashProps.HostConsoleVersion = $host.Version
    $HashProps.HostCulture = $host.CurrentCulture
    $HashProps.HostCultureUI = $host.CurrentUICulture

    # Gather Rubrik Cluster information
    if ($RubrikConnection) {
        $HashProps.RubrikConnection = $true
        $HashProps.UserAgentString = $RubrikConnection.header.'User-Agent'
        $HashProps.RubrikAuthentication = $RubrikConnection.header.authorization.split(' ')[0].SubString(0, 6)
        $HashProps.RubrikClusterVersion = $RubrikConnection.version
    } else {
        Write-Warning "This cmdlet can gather more information if you're connected to your Rubrik Cluster"
    }

    # Add module information
    $HashProps.RubrikCurrentModuleVersion = (Get-Module -Name Rubrik) | ForEach-Object {'{0}-{1}' -f $_.Version,$_.PrivateData.PSData.Prerelease}
    $HashProps.RubrikInstalledModule = ((Get-Module -Name Rubrik -ListAvailable) | ForEach-Object {if ($_.PrivateData.PSData.Prerelease -ne $null) {'{0}-{1}' -f $_.Version,$_.PrivateData.PSData.Prerelease} else {$_.version}}) -join ', '

    # Output as object
    return [pscustomobject]$HashProps

  } # End of process
} # End of function