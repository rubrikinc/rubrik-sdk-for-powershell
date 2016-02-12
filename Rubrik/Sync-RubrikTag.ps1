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

        Write-Verbose -Message 'Validate the Rubrik token exists'
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        Write-Verbose -Message 'Allowing self-signed certificates'
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
        
        Write-Verbose -Message 'Gather the SLA Domains'
        $sladomain = Get-RubrikSLA

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

        Write-Verbose -Message 'Validate the tag category exists'
        $category_name = 'Rubrik_SLA'
        if (-not ((Get-TagCategory) -match $category_name)) 
        {
            New-TagCategory -Name $category_name -Description 'Rubrik SLA Domains' -Cardinality Single
        }
       
        Write-Verbose -Message 'Validate the tags exist'
        foreach ($_ in $sladomain)
        {
            New-Tag -Name $_.name -Category $category_name -ErrorAction SilentlyContinue
        }
        
        Write-Verbose -Message 'Create the Unprotected assignment for VMs without an SLA Domain'
        New-Tag -Name 'Unprotected' -Category $category_name -ErrorAction SilentlyContinue
        
        Write-Verbose -Message 'Submit the request to determine SLA Domain assignments to VMs'
        $uri = 'https://'+$global:RubrikServer+':443/vm'
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
        
        Write-Verbose -Message 'Assign tags to the VMs that have SLA Domain assignments'
        foreach ($_ in $response)
        {
            if ($_.effectiveSlaDomainName) 
            {
                New-TagAssignment -Tag (Get-Tag -Name $_.effectiveSlaDomainName) -Entity $_.name
            }
        }

        Write-Verbose -Message 'Disconnect from vCenter'
        Disconnect-VIServer -Confirm:$false

    } # End of process
} # End of function