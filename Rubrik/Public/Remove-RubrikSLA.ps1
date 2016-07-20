#Requires -Version 3
function Remove-RubrikSLA 
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and removes SLA Domains
            .DESCRIPTION
            The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain. The SLA Domain must have zero protected VMs in order to be successful.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Remove-RubrikSLA -SLA 'Gold'
            This will attempt to remove the Gold SLA Domain from Rubrik if there are no VMs being protected by the policy
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

        Write-Verbose -Message 'Gather the Rubrik SLA Domain ID value'
        [array]$slaid = Get-RubrikSLA -SLA $SLA

        Write-Verbose -Message 'Determining if SLA Domain has zero VMs'
        if ($slaid.numVms -ne 0) 
        {
            throw "SLA Domain has $($slaid.numVms) VMs protected - remove them and retry."
        }
        
        foreach ($_ in $slaid.id) {
        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$Server+'/slaDomain/'+$_

        Write-Verbose -Message 'Submit the request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Delete
        }
        catch 
        {
            throw $_
        }
        }

    } # End of process
} # End of function