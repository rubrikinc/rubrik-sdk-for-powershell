function Get-RubrikSnapshot
{
    <#  
            .SYNOPSIS
            Retrieves all of the snapshots (backups) for a given virtual machine
            .DESCRIPTION
            The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for a protected virtual machine
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Get-RubrikSnapshot -VM 'Server1'
            This will return an array of details for each snapshot (backup) for Server1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Required variable')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Query Rubrik for the list of protected VM details'
        $vmid = (Get-RubrikVM -VM $VM).id

        Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
        $uri = 'https://'+$Server+'/snapshot?vm='+$vmid
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content)
            if (!$result) 
            {
                throw 'No snapshots found for VM.'
            }
            else {return $result}
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function