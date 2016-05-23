#Requires -Version 3
function Remove-RubrikMount
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and removes one or more instant mounts
            .DESCRIPTION
            The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Remove-RubrikMount -VM "Prod-SQL"
            This will remove any Instant Mounts found for a VM matching the name "Prod-SQL" in vSphere.
            .EXAMPLE
            Remove-RubrikMount -VM "Prod-SQL" -MountID 4
            This will remove Instant Mount ID #4 from the VM matching the name "Prod-SQL" in vSphere. The Mount ID is appended to the end of the Instant Mount name.
            .EXAMPLE
            Remove-RubrikMount -RemoveAll
            This will remove all Instant Mounts found for the Rubrik Cluster, and is handy as a way to "refresh" a test/dev environment.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Virtual Machine to inspect for mounts',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'The specific mount ID to remove',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Int]$MountID,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'The Rubrik ID value of the mount',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$RubrikID,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Remove all instant mounts for all VMs',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$RemoveAll,
        [Parameter(Mandatory = $false,Position = 4,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        Write-Verbose -Message 'Validating user input of MountID'
        if ($MountID -lt 0) 
        {
            throw 'Only positive integers are allowed for MountID'
        }        
        elseif ($MountID -eq '') 
        {
            $MountID = -1
        }
        Write-Verbose -Message "MountID set to $MountID"

        Write-Verbose -Message 'Validating user input of VM selection'        
        if ($VM)
        {
            try
            {
                Write-Verbose -Message "Gathering mount details for $VM"
                [array]$mounts = Get-RubrikMount -VM $VM
                if (!$mounts)
                {
                    throw "No mounts found for $VM"
                }
                else 
                {
                    Write-Verbose -Message "Mounts found for $VM"
                }
            }
            catch
            {
                throw $_
            }
        }
        elseif ($RemoveAll)
        {
            try
            {
                Write-Verbose -Message 'Gathering mount details for all VMs'
                [array]$mounts = Get-RubrikMount -VM *
                if (!$mounts)
                {
                    throw 'No mounts found for any VMs'
                }
                else 
                {
                    Write-Verbose -Message 'Mounts found for all VMs'
                }
            }
            catch
            {
                throw $_
            }
        }
        elseif ($RubrikID)
        {
            Write-Verbose -Message "Using a specific Rubrik Mount ID of $RubrikID"
            [array]$mounts = @{
                MountName = 'Manual_ID_Entry'
                RubrikID  = $RubrikID
            }
        }
        else 
        {
            throw 'Use -VM to select a single VM, -RubrikID to specify a Rubrik Mount ID value, or -RemoveAll to remove mounts from all VMs'
        }

        $uri = 'https://'+$Server+'/job/type/unmount'

        foreach ($_ in $mounts)
        {
            $body = @{
                mountId = $_.RubrikID
                force   = 'false'
            }

            Write-Verbose -Message 'Determing the MountID of the Instant Mount'
            if ($MountID -eq ($_.MountName.split(' ')[-1]) -or $MountID -eq -1)
            {
                try 
                {
                    Write-Verbose -Message "Removing mount with ID $($_.RubrikID)"
                    $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method POST -Body (ConvertTo-Json -InputObject $body)
                    if ($r.StatusCode -ne '200') 
                    {
                        throw 'Did not receive successful status code from Rubrik for Mount removal request'
                    }
                    Write-Verbose -Message "Success: $($r.Content)"
                }
                catch 
                {
                    throw $_
                }
            }
        }

    } # End of process
} # End of function