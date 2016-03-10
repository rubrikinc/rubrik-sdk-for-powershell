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
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        $VM,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Target Network Portgroup for VM')]
        [ValidateNotNullorEmpty()]
        [String]$Portgroup
    )

    Process {

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        Write-Verbose -Message 'Importing required modules and snapins'
        $powercli = Get-PSSnapin -Name VMware.VimAutomation.Core -Registered
        try 
        {
            switch ($powercli.Version.Major) {
                {
                    $_ -ge 6
                }
                {
                    Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
                    Write-Verbose -Message 'PowerCLI 6+ module imported'
                }
                5
                {
                    Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop
                    Write-Warning -Message 'PowerCLI 5 snapin added; recommend upgrading your PowerCLI version'
                }
                default 
                {
                    throw 'This script requires PowerCLI version 5 or later'
                }
            }
        }
        catch 
        {
            throw $_
        }


        Write-Verbose -Message 'Ignoring self-signed SSL certificates for vCenter Server (optional)'
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        Write-Verbose -Message 'Connecting to vCenter'
        try 
        {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
                    $_.name -eq $vCenter
            }).sessionId
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }

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