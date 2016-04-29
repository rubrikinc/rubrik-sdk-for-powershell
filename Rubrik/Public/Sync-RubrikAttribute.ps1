#Requires -Version 3
function Sync-RubrikAnnotation
{
    <#  
            .SYNOPSIS
            Applies Rubrik SLA Domain information to VM Attributes using Custom Attributes in vCenter
            .DESCRIPTION
            The Sync-RubrikAttribute cmdlet will comb through all VMs currently being protected by Rubrik. It will then create Custom Attribute buckets for Rubrik_SLA and Rubrik_Backups and assign details for each VM found in vCenter using Annotations.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikConnection.server
    )

    Process {

        TestRubrikConnection

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

        
        # Query Rubrik for SLA Domain Information
        $uri = 'https://'+$Server+'/vm'

        # Submit the request
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method Get
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

        # Report the results
        $result = ConvertFrom-Json -InputObject $r.Content 
        if ($SLA) 
        {
            $result = $result | Where-Object -FilterScript {
                $_.slaDomainName -match $SLA
            }
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

        # Validate custom annotation exists in vCenter
        if (-not (Get-CustomAttribute -Name 'Rubrik_SLA')) 
        {
            New-CustomAttribute -Name 'Rubrik_SLA' -TargetType VirtualMachine
        }
        if (-not (Get-CustomAttribute -Name 'Rubrik_Backups')) 
        {
            New-CustomAttribute -Name 'Rubrik_Backups' -TargetType VirtualMachine
        }

        # Set annotation on VMs in vCenter
        foreach ($_ in $result)
        {
            if ($_.slaDomainName)
            {
                $null = Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute 'Rubrik_SLA' -Value $_.slaDomainName
                $null = Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute 'Rubrik_Backups' -Value $_.snapshotCount
                Write-Host -Object "Successfully tagged $($_.name) as $($_.effectiveSlaDomainName)"
            }
        }

        # Disconnect from vCenter
        Disconnect-VIServer -Confirm:$false

    } # End of process
} # End of function