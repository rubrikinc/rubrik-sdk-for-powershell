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
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Source Virtual Machine',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        [String]$SourceVM,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Target Virtual Machine',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$TargetVM,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $true,Position = 3,HelpMessage = 'Backup date in MM/DD/YYYY HH:MM format',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Date,
        [Parameter(Mandatory = $false,Position = 4,HelpMessage = 'Rubrik FQDN or IP address')]
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
            throw $_
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


        Write-Verbose -Message 'Creating an Instant Mount (clone) of the Source VM'
        New-RubrikMount -VM $SourceVM -Date $Date
        Start-Sleep -Seconds 2
        [array]$mounts = Get-RubrikMount -VM $SourceVM
        $i = 0
        
        Write-Verbose -Message 'Checking for quantity of mounts in the system'
        if ($mounts -ne $null) 
        {
            Write-Verbose -Message 'Finding the correct mount'
            foreach ($_ in $mounts.MountName)
            {            
                if ($_ -eq $null)
                {
                    break
                }
                $i++
            }
        
        While ($mounts[$i].MountName -eq $null)
        {
            [array]$mounts = Get-RubrikMount -VM $SourceVM
            Start-Sleep -Seconds 2
        }
        }
        else
        {
        Write-Verbose -Message 'No other mounts found, waiting for new mount to load'
        While ($mounts.MountName -eq $null)
        {
            [array]$mounts = Get-RubrikMount -VM $SourceVM
            Start-Sleep -Seconds 2
        }
        }
        Write-Verbose -Message 'Mount is online. vSphere data loaded into the system.'

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
        $MountVM = $null
        While ($MountVM.PowerState -ne 'PoweredOn')
        {
            $MountVM = Get-VM -Name $mounts[$i].MountName
            Start-Sleep -Seconds 2
        }

        Write-Verbose -Message 'Powering off the Instant Mount'
        $null = Stop-VM -VM $MountVM -Confirm:$false

        Write-Verbose -Message 'Gathering details on the Target VM'
        if (!$TargetVM) 
        {
            $TargetVM = $SourceVM
        }
        $TargetHost = Get-VMHost -VM $TargetVM

        Write-Verbose -Message 'Mounting Rubrik datastore to the Target Host'
        $MountDatastore = Get-VM $MountVM | Get-Datastore
        if (!(Get-VMHost $TargetHost | Get-Datastore -Name $MountDatastore)) 
        {
            $null = New-Datastore -Name $MountDatastore.Name -VMHost $TargetHost -NfsHost $MountDatastore.RemoteHost -Path $MountDatastore.RemotePath -Nfs
        }

        Write-Verbose -Message 'Migrating the Mount VMDKs to VM'
        [array]$MountVMdisk = Get-HardDisk $MountVM
        foreach ($_ in $MountVMdisk)
        {
            try
            {
                $null = Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
                $null = New-HardDisk -VM $TargetVM -DiskPath $_.Filename
            }
            catch
            {
                throw 'Unable to attach VMDKs to the TargetVM'
            }
        }
        
        Write-Verbose -Message 'Offering cleanup options'
        $title = 'Setup is complete!'
        $message = "A Mount of $SourceVM has been created, and all VMDKs associated with the mount have been attached.`rYou may now start testing.`r`rWhen finished:`rSelect YES to automatically cleanup the attached VMDKs and mount`rSelect NO to leave the mount and VMDKs intact."

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
                [array]$SourceVMdisk = Get-HardDisk $TargetVM
                foreach ($_ in $SourceVMdisk)
                {
                    if ($_.Filename -eq $MountVMdisk.Filename)
                    {
                        Write-Verbose -Message "Removing $_ from $TargetVM"
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