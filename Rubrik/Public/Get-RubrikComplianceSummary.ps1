#requires -Version 3
function Get-RubrikComplianceSummary
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves protection complance summary
            .DESCRIPTION
            The Get-RubrikComplianceSummary return a short sumamry showing protected,unproteced and non compliant VMs
            .NOTES
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikComplianceSummary
            Will return a sumamry like this:
            compliantVmsCount nonCompliantVmsCount unprotectedVmsCount
            ----------------- -------------------- -------------------
              235                    0                 226
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        $uri = 'https://'+$Server+'/report/slaCompliance/summary'


        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method get
        $result = (ConvertFrom-Json -InputObject $r.Content)
        return $result

    } # End of process
} # End of function
