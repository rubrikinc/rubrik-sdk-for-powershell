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
            .EXAMPLE
            Get-RubrikMount -VM Server1
            Will return all Live Mounts found for Server1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine to inspect for mounts',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        Write-Verbose -Message 'Query Rubrik for any active live mounts'
        $uri = 'https://'+$Server+'/mount'

        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Get
            $response = ConvertFrom-Json -InputObject $r.Content
            [array]$mount = $response | Where-Object -FilterScript {
                $_.sourcevirtualMachineName -like $VM
            }
            if (!$mount) 
            {
                Write-Verbose -Message "No mounts found for $VM"
            }
            else 
            {
                Write-Verbose -Message "Found $($mount.count) mounts for $VM"
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
                return $result
            }
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function