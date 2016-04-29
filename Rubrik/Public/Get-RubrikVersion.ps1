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
            .EXAMPLE
            Get-RubrikVersion
            This will return the running version on the Rubrik cluster
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        Write-Verbose -Message 'Query Rubrik for SLA Domain Information'
        $uri = 'https://'+$Server+'/system/version'

        try 
        {
            $r = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri $uri -Headers $Header -Method Get).Content
            return $r
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function