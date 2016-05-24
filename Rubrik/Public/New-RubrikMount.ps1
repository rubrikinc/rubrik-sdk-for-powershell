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
            .EXAMPLE
            New-RubrikMount -VM 'Server1' -Date '05/04/2015 08:00'
            This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal to or older than 08:00 AM on May 4th, 2015
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
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Query Rubrik for the list of protected VM details'
        $hostid = (Get-RubrikVM -VM $VM).hostId

        Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
        $snapshots = Get-RubrikSnapshot -VM $VM

        Write-Verbose -Message 'Comparing backup dates to user date'
        $Date = ConvertFromLocalDate -Date $Date
        
        Write-Verbose -Message 'Finding snapshots that match the date value'
        foreach ($_ in $snapshots)
            {
            if (([datetime]$_.date) -le ($Date) -eq $true)
                {
                $vmsnapid = $_.id
                Write-Verbose -Message "Found matching snapshot with ID $vmsnapid"
                break
                }
            }

        Write-Verbose -Message 'Creating a Live Mount'
        $uri = 'https://'+$Server+'/job/type/mount'

        $body = @{
            snapshotId     = $vmsnapid
            hostId         = $hostid
            disableNetwork = $true
        }

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Post -Body (ConvertTo-Json -InputObject $body)
            if ($r.StatusCode -ne '200') 
            {
                throw 'Did not receive successful status code from Rubrik for Live Mount request'
            }
            Write-Verbose -Message "Success: $($r.Content)"
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function