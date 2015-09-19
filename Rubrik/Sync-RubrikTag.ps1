#Requires -Version 3
function Sync-RubrikTag
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and creates a vSphere tag for each SLA Domain
            .DESCRIPTION
            The Sync-RubrikTag cmdlet will query Rubrik for all of the existing SLA Domains, and then create a tag for each one
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
        
        # Gather the SLA Domains
        $sladomain = Get-RubrikSLA

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


        # Ignore self-signed SSL certificates for vCenter Server (optional)
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        # Connect to vCenter
        try 
        {
            $null = Connect-VIServer -Server $vcenter -ErrorAction Stop
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }

        # Validate the tag category exists
        $category_name = 'Rubrik_SLA'
        if (-not ((Get-TagCategory) -match $category_name)) {New-TagCategory -Name $category_name -Description 'Rubrik SLA Domains' -Cardinality Single}
       
        # Validate the tags exist
        foreach ($_ in $sladomain)
            {
            New-Tag -Name $_.name -Category $category_name
            }
        
        # Assign tags to VMs


        
        # Disconnect from vCenter
        Disconnect-VIServer -Confirm:$false

    } # End of process
} # End of function