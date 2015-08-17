#Requires -Version 3
function New-RubrikSnapshot
{
    <#  
            .SYNOPSIS
            Takes a Rubrik snapshot of a virtual machine
            .DESCRIPTION
            The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be taken by
            Rubrik and stored in the VM's chain of snapshots.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine to backup',ValueFromPipeline=$true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        # Query Rubrik for the VM ID
        $uri = 'https://'+$global:RubrikServer+':443/vm'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content) | Where-Object {$_.name -eq $VM}
            if (!$result) {throw 'No VM found with that name.'}
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

        # Submit the request for an On-Demand Backup
        $uri = 'https://'+$global:RubrikServer+':443/internal/job/type/backup'

        $body = @{
          vmId = $result.id
          isOnDemandSnapshot = "true"
        }

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Post -Body (ConvertTo-Json -InputObject $body)
            Write-Host "A new on-demand backup job has been created for $($result.name).`r`nThe job ID is as follows:`r`n$($r.Content)"
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }


    } # End of process
} # End of function