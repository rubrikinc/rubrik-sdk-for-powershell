#Requires -Version 3
function New-RubrikMount
{
    <#  
            .SYNOPSIS
            Create a new Live Mount from a protected VM
            .DESCRIPTION
            The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine to mount',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Backup date in MM/DD/YYYY HH:MM format',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Date,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        Write-Verbose -Message 'Validating the Rubrik API token exists'
        if (-not $global:RubrikToken) 
        {
            Write-Warning -Message 'You are not connected to a Rubrik server. Using Connect-Rubrik cmdlet.'
            Connect-Rubrik
        }

        Write-Verbose -Message 'Query Rubrik for the list of protected VM details'
        $uri = 'https://'+$global:RubrikServer+':443/vm?showArchived=false'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content) | Where-Object -FilterScript {
                $_.name -eq $VM
            }
            if (!$result) 
            {
                throw 'No VM found with that name.'
            }
            $vmid = $result.id
            $hostid = $result.hostId
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

        Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
        $uri = 'https://'+$global:RubrikServer+':443/snapshot?vm='+$vmid
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $result = (ConvertFrom-Json -InputObject $r.Content)
            if (!$result) 
            {
                throw 'No snapshots found for VM.'
            }
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

        Write-Verbose -Message 'Comparing backup dates to user date'
        $Date = $Date -as [datetime]
        if (!$Date) {throw "You did not enter a valid date and time"}
        foreach ($_ in $result)
            {
            if ((Get-Date $_.date) -lt (Get-Date $Date) -eq $true)
                {
                $vmsnapid = $_.id
                break
                }
            }

        Write-Verbose -Message 'Creating a Live Mount'
        $uri = 'https://'+$global:RubrikServer+':443/job/type/mount'

        $body = @{
            snapshotId     = $vmsnapid
            hostId         = $hostid
            disableNetwork = 'true'
        }

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Post -Body (ConvertTo-Json -InputObject $body)
            if ($r.StatusCode -ne '200') 
            {
                throw 'Did not receive successful status code from Rubrik for Live Mount request'
            }
            Write-Verbose -Message "Success: $($r.Content)"
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

    } # End of process
} # End of function