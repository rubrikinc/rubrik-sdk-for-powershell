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
        # Import modules or snapins
        $powercli = Get-PSSnapin -Name VMware.VimAutomation.Core -Registered

        try 
        {
            switch ($powercli.Version.Major) {
                {
                    $_ -ge 6
                }
                {
                    Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
                    Write-Host -Object 'PowerCLI 6+ module imported'
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

        
        # Allow untrusted SSL certs
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


        # Create a Mount of Prod VM

        [array]$mounts = Get-RubrikMount -VM $VM
        if (!$mounts)
        {
            New-RubrikMount -VM $VM
            While ($mounts.MountName -eq $null)
                {
                [array]$mounts = Get-RubrikMount -VM $VM
                Start-Sleep -Seconds 2
                }
            Write-Host "Mount is online. vSphere data loaded into the system."
        }

        # Ignore self-signed SSL certificates for vCenter Server (optional)
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        # Connect to vCenter
        try 
        {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }
    
        # Get details on the Mount

        $mountvm = $null
        While ($mountvm.PowerState -ne 'PoweredOn')
            {
            $mountvm = Get-VM -Name $mounts[0].MountName
            Sleep 2
            }

        # Power off the Mount

        Stop-VM -VM $mountvm -Confirm:$false

        # Migrate Mount VMDKs to Prod VM

        [array]$mountvmdisk = Get-HardDisk $mountvm
        foreach ($_ in $mountvmdisk)
        {
            Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
            New-HardDisk -VM $VM -DiskPath $_.Filename
        }
        
        # Pause for user testing
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
                # Remove VMDKs from Prod VM
                [array]$vmdisk = Get-HardDisk $VM
                foreach ($_ in $vmdisk)
                {
                    if ($_.Filename -eq $mountvmdisk.Filename)
                    {
                        Write-Host -Object "Removing $_ from $VM"
                        Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
                    }
                }
        
                # Delete the Mount                
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
                    Write-Host -Object "Success: $($r.Content)"
                }
                catch 
                {
                    throw 'Error connecting to Rubrik server'
                }
            }
            1 
            {
                'You selected No. Exiting script'
            }
        }



    } # End of process
} # End of function