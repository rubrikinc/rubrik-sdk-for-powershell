#Requires -Version 3
function New-RubrikSnapshot
{
    <#  
            .SYNOPSIS
            Takes a Rubrik snapshot of a virtual machine
            .DESCRIPTION
            The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be taken by Rubrik and stored in the VM's chain of snapshots.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            New-RubrikSnapshot -VM 'Server1'
            This will trigger an on-demand backup for the virtual machine named Server1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine to backup',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Gathering VM ID value from Rubrik'
        $vmid = (Get-RubrikVM -VM $VM).id

        Write-Verbose -Message 'Submit the request for an On-Demand Backup'
        $uri = 'https://'+$Server+'/internal/job/type/backup'

        $body = @{
            vmId               = $vmid
            isOnDemandSnapshot = 'true'
        }

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Post -Body (ConvertTo-Json -InputObject $body)
            Write-Verbose -Message $r.Content
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function