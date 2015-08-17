#Requires -Version 3
function Get-RubrikSLA 
{
     <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves details on SLA Domain(s)
            .DESCRIPTION
            The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information on each
            domain will be reported to the console.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$SLA,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

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

        # Validate the Rubrik token exists
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }
        
        # Build the URI
        $uri = 'https://'+$server+':443/slaDomain'

        # Submit the request
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Get
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }

        # Report the results
        $result = ConvertFrom-Json -InputObject $r.Content 
        if ($sla) 
        {
            $result | Where-Object -FilterScript {
                $_.name -match $sla
            }
        }
        else 
        {
            $result
        }

    } # End of process
} # End of function