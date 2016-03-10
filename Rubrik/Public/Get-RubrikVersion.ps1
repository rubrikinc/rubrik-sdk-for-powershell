#Requires -Version 3
function Get-RubrikVersion
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves the current version
            .DESCRIPTION
            The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }
        
        # Query Rubrik for SLA Domain Information
        $uri = 'https://'+$global:RubrikServer+':443/system/version'

        # Submit the request
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            ConvertFrom-Json -InputObject $r.Content
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }


    } # End of process
} # End of function