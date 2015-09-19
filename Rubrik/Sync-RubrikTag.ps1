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

        # Query Rubrik for SLA Domain Information
        $uri = 'https://'+$global:RubrikServer+':443/vm/list'

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
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }

        # Validate the tag category exists
        $category_name = 'Rubrik_SLA'
        if (-not ((Get-TagCategory) -match $category_name)) 
        {
            New-TagCategory -Name $category_name -Description 'Rubrik SLA Domains' -Cardinality Single
        }
       
        # Validate the tags exist
        foreach ($_ in $sladomain)
        {
            New-Tag -Name $_.name -Category $category_name -ErrorAction SilentlyContinue
        }
        
        # Create the Unprotected assignment for VMs without an SLA Domain
        New-Tag -Name 'Unprotected' -Category $category_name -ErrorAction SilentlyContinue
        
        # Submit the request to determine SLA Domain assignments to VMs
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
            $response = ConvertFrom-Json -InputObject $r.Content            
        }
        catch 
        {
            $ErrorMessage = $_.Exception.Message
            throw "Error connecting to Rubrik server: $ErrorMessage"
        }
        
        # Assign tags to the VMs that have SLA Domain assignments
        foreach ($_ in $response)
        {
            if ($_.slaDomainName) 
            {
                New-TagAssignment -Tag (Get-Tag -Name $_.slaDomainName) -Entity $_.name
            }
        }

        # Disconnect from vCenter
        Disconnect-VIServer -Confirm:$false

    } # End of process
} # End of function