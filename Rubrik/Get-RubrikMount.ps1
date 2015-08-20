#Requires -Version 3
function Get-RubrikMount
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves details on mounts for a VM
            .DESCRIPTION
            The Get-RubrikMount cmdlet will accept a VM name and return details on any mount operations that are active within Rubrik
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine to inspect for mounts',ValueFromPipeline = $true)]
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
        
        # Query Rubrik for SLA Domain Information
        $uri = 'https://'+$global:RubrikServer+':443/mount'

        # Submit the request
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $response = ConvertFrom-Json -InputObject $r.Content
            [array]$mount = $response | Where-Object -FilterScript {
                $_.snapshot.virtualMachineName -eq $VM
            }
            if (!$mount) 
            {
                Write-Host -Object "No mounts found for $VM"
                break
            }
        }
        catch 
        {
            $ErrorMessage = $_.Exception.Message
            throw "Error connecting to Rubrik server: $ErrorMessage"
        }

        # Send mount details to $result and console
        Write-Host -Object "Found $($mount.count) mounts for $VM"
        $result = $mount | Select-Object -Property @{
            N = 'MountName'
            E = {
                $_.virtualMachine.name
            }
        }, @{
            N = 'MOID'
            E = {
                $_.virtualMachine.moid
            }
        }, @{
            N = 'HostID'
            E = {
                $_.virtualMachine.hostID
            }
        }, @{
            N = 'vCenterID'
            E = {
                $_.virtualMachine.vCenterID
            }
        }, @{
            N = 'RubrikID'
            E = {
                $_.id
            }
        }
        $result | Format-Table -AutoSize


    } # End of process
} # End of function