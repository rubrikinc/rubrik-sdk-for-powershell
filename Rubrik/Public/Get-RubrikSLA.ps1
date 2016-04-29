#Requires -Version 3
function Get-RubrikSLA 
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves details on SLA Domain(s)
            .DESCRIPTION
            The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information on each
            domain will be reported to the console.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikSLA
            Will return all known SLA Domains
            .EXAMPLE
            Get-RubrikSLA -SLA 'Gold'
            Will return details on the SLA Domain named Gold
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        Write-Verbose -Message 'Retrieving SLA Domains from Rubrik'
        $uri = 'https://'+$Server+'/slaDomain'

        try 
        {
            $result = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri $uri -Headers $Header -Method Get).Content
        }
        catch 
        {
            throw $_
        }

        Write-Verbose -Message 'Returning the SLA Domain results'
        if ($SLA) 
        {
            return $result | Where-Object -FilterScript {
                $_.name -match $SLA
            }
        }
        else 
        {
            return $result
        }

    } # End of process
} # End of function