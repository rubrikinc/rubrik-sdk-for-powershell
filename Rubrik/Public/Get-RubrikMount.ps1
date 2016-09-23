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
            .EXAMPLE
            Get-RubrikMount -ID 1234567890
            Will return all Live Mounts found for the Rubrik ID 1234567890
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'Virtual Machine to inspect for mounts',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik mount ID value',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$ID,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:rubrikConnection.server
    )

    Process {

        TestRubrikConnection
        
        try 
        {
            if ($VM) 
            {
                Write-Verbose -Message 'Query Rubrik for any active live mounts based on VM name'
                $uri = 'https://'+$Server+'/mount'
                $r = Invoke-WebRequest -Uri $uri -Headers $header -Method Get

                $response = ConvertFrom-Json -InputObject $r.Content
                [array]$mount = $response | Where-Object -FilterScript {
                    $_.sourcevirtualMachineName -like $VM
                }
            }

            elseif ($ID) 
            {
                Write-Verbose -Message 'Query Rubrik for a specific mount ID value'
                $uri = 'https://'+$Server+'/mount/'+$ID
                $r = Invoke-WebRequest -Uri $uri -Headers $header -Method Get
                $mount = ConvertFrom-Json -InputObject $r.Content
            }
            else 
            {
                throw 'You must provide either a VM name or ID value'
            }
            
            if (!$mount) 
            {
                Write-Verbose -Message "No mounts found for $VM"
            }
            else 
            {
                return $mount
            }
        }
        catch 
        {
            throw $_
        }


    } # End of process
} # End of function