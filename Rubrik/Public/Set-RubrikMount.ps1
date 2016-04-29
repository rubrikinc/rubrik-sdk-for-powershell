#requires -PSSnapin VMware.VimAutomation.Core
#Requires -Version 2
function Set-RubrikMount
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and sets configuration details for one or more instant mounts
            .DESCRIPTION
            The Set-RubrikMount cmdlet is used to update configuration details for a running instant mount.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Set-RubrikMount -VM 'Server1' -vCenter 'VC1.example.com' -Portgroup 'Production-VLAN10'
            This would change the network settings on Server1's Live Mount to the Production-VLAN10 portgroup and enable the network connection
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$VM,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Target Network Portgroup for VM')]
        [ValidateNotNullorEmpty()]
        [String]$Portgroup,
        [Parameter(Mandatory = $false,Position = 3,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

        ConnectTovCenter -vCenter $vCenter

        Write-Verbose -Message "Gathering VM details from $VM"
        $Mount = Get-VM ((Get-RubrikMount -VM $VM).MountName)

        if ($Portgroup -ne '') 
        {
            Write-Verbose -Message "Setting portgroup configuration to $Portgroup with connected virtual network adapter"
            try 
            {
                $null = Get-VirtualPortGroup -Name $Portgroup
            }
            catch 
            {
                throw "No portgroup with name $Portgroup was found"
            }
            $null = $Mount |
            Get-NetworkAdapter |
            Set-NetworkAdapter -NetworkName $Portgroup -StartConnected:$true -Connected:$true -Confirm:$false
            Write-Verbose -Message "Network portgroup updated for $VM"
        }


    } # End of process
} # End of function