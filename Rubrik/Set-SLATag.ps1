#Requires -Version 3
function Set-SLATag
{
    <#  
            .SYNOPSIS  Applies Rubrik SLA Domain information to VM tags in vCenter
            .DESCRIPTION Applies Rubrik SLA Domain information to VM tags in vCenter
            .NOTES  Author:  Chris Wahl, chris.wahl@rubrik.com
            .PARAMETER vCenter
            The vCenter FQDN or IP address
            .PARAMETER Name
            A specific SLA Domain to tag
            .EXAMPLE
            PS> tbd
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'vCenter FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$vcenter,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$name
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

        # Validate token and build Base64 Auth string
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }
        else {Write-Host 'Connecting to the Rubrik API ...'}
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($global:RubrikToken+':'))
        $head = @{
            'Authorization' = "Basic $auth"
        }
        
        # Query Rubrik for SLA Domain Information
        $uri = 'https://'+$server+':443/vm'

        # Submit the request
        $r = Invoke-WebRequest -Uri $uri -Headers $head -Method Get

        # Report the results
        $result = ConvertFrom-Json -InputObject $r.Content 
        if ($name) 
        {
            $result = $result | Where-Object -FilterScript {
                $_.slaDomainName -match $name
            }
        }
        else 
        {
            $result
        }

        # Ignore self-signed SSL certificates for vCenter Server (optional)
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        # Connect to vCenter
        try 
        {
            $null = Connect-VIServer $vcenter -Credential $creds -ErrorAction Stop
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }

        # Validate custom annotation exists in vCenter
        if (-not (Get-CustomAttribute -Name 'Rubrik_SLA')) {New-CustomAttribute -Name 'Rubrik_SLA' -TargetType VirtualMachine}
        if (-not (Get-CustomAttribute -Name 'Rubrik_Backups')) {New-CustomAttribute -Name 'Rubrik_Backups' -TargetType VirtualMachine}

        # Set annotation on VMs in vCenter
        foreach ($_ in $result)
            {
            if ($_.slaDomainName)
                {
                Set-Annotation (Get-VM -id ('VirtualMachine-'+$_.moid)) -CustomAttribute 'Rubrik_SLA' -Value $_.slaDomainName | Out-Null
                Set-Annotation (Get-VM -id ('VirtualMachine-'+$_.moid)) -CustomAttribute 'Rubrik_Backups' -Value $_.snapshotCount | Out-Null
                Write-Host "Successfully tagged $($_.name)"
                }
            }

    } # End of process
} # End of function