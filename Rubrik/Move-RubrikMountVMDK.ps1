#Requires -Version 3
function Move-RubrikMountVMDK
{
    <#  
            .SYNOPSIS
            Moves the VMDKs from a Live Mount to another VM
            .DESCRIPTION
            The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.
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
        [String]$VM,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
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
            throw 'Could not load the required VMware.VimAutomation.Core cmdlets'
        }

        
        Write-Verbose -Message 'Allowing untrusted SSL certs'
        Add-Type -TypeDefinition @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy


        Write-Verbose -Message 'Creating an Instant Mount (clone) of the VM'
        [array]$mounts = Get-RubrikMount -VM $VM
        if (!$mounts)
        {
            New-RubrikMount -VM $VM
            While ($mounts.MountName -eq $null)
            {
                [array]$mounts = Get-RubrikMount -VM $VM
                Start-Sleep -Seconds 2
            }
            Write-Verbose -Message 'Mount is online. vSphere data loaded into the system.'
        }

        Write-Verbose -Message 'Ignoring self-signed SSL certificates for vCenter Server (optional)'
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        Write-Verbose -Message 'Connecting to vCenter'
        try 
        {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }
    
        Write-Verbose -Message 'Gathering details on the Instant Mount'
        $mountvm = $null
        While ($mountvm.PowerState -ne 'PoweredOn')
        {
            $mountvm = Get-VM -Name $mounts[0].MountName
            Start-Sleep -Seconds 2
        }

        Write-Verbose -Message 'Powering off the Instant Mount'
        $null = Stop-VM -VM $mountvm -Confirm:$false

        Write-Verbose -Message 'Migrating the Mount VMDKs to VM'
        [array]$mountvmdisk = Get-HardDisk $mountvm
        foreach ($_ in $mountvmdisk)
        {
            $null = Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
            $null = New-HardDisk -VM $VM -DiskPath $_.Filename
        }
        
        Write-Verbose -Message 'Offering cleanup options'
        $title = 'Setup is complete!'
        $message = "A Mount of $VM has been created, and all VMDKs associated with the mount have been attached. You may now start testing.`r`rWhen finished, select YES to automatically cleanup the attached VMDKs and mount, or select NO to leave the mount and VMDKs intact."

        $yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', `
        'Automated Removal: This script will detatch the VMDK(s) and discard the Mount VM'

        $no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No', `
        'Manual Removal: VMDK(s) will remain attached and Mount VM will remain in vCenter'

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

        $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

        switch ($result)
        {
            0 
            {
                Write-Verbose -Message 'Removing VMDKs from the VM'
                [array]$vmdisk = Get-HardDisk $VM
                foreach ($_ in $vmdisk)
                {
                    if ($_.Filename -eq $mountvmdisk.Filename)
                    {
                        Write-Verbose -Message "Removing $_ from $VM"
                        Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
                    }
                }
        
                Write-Verbose -Message 'Deleting the Instant Mount'
                $uri = 'https://'+$global:RubrikServer+':443/job/type/unmount'

                $body = @{
                    mountId = $mounts[0].RubrikID
                    force   = 'false'
                }

                try 
                {
                    $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method POST -Body (ConvertTo-Json -InputObject $body)
                    if ($r.StatusCode -ne '200') 
                    {
                        throw 'Did not receive successful status code from Rubrik for Mount removal request'
                    }
                    Write-Verbose -Message "Success: $($r.Content)"
                }
                catch 
                {
                    throw 'Error connecting to Rubrik server'
                }
            }
            1 
            {
                Write-Verbose -Message 'You selected No. Exiting script'
            }
        }

    } # End of process
} # End of function