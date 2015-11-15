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
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Virtual Machine to inspect for mounts',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Remove all instant mounts for all VMs',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [Switch]$RemoveAll,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        # are we removing one or multiple?
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
                    Write-Verbose -Message "Unmounting all mounts found for $VM"
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
                    Write-Verbose -Message 'Unmounting all mounts found for all VMs'
                }
            }
            catch
            {
                throw $_
            }
        }
        else 
        {
            throw 'Use -VM to select a single VM, or -RemoveAll to remove mounts from all VMs'
        }

        $uri = 'https://'+$global:RubrikServer+':443/job/type/unmount'

        foreach ($_ in $mounts)
        {
            $body = @{
                mountId = $_.RubrikID
                force   = 'false'
            }
            try 
            {
                Write-Verbose -Message "Removing mount with ID $($_.RubrikID)"
                $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method POST -Body (ConvertTo-Json -InputObject $body)
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

    } # End of process
} # End of function