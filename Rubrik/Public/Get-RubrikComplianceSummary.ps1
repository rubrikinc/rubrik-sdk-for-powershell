#requires -Version 3
function Get-RubrikComplianceSummary
{
    <#  

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Submit sla compliance state for all/one vms'
        $uri = 'https://'+$Server+'/report/slaCompliance/summary'


        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method get
        $result = (ConvertFrom-Json -InputObject $r.Content)
        return $result

    } # End of process
} # End of function
