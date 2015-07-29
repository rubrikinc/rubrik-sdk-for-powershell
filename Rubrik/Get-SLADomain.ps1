#Requires -Version 3
function Get-SLADomain 
{
    <#  
            .SYNOPSIS  Connects to Rubrik and retrieves details on SLA Domain(s)
            .DESCRIPTION Connects to Rubrik and retrieves details on SLA Domain(s)
            .NOTES  Author:  Chris Wahl, chris.wahl@rubrik.com
            .PARAMETER Name
            A specific SLA Domain to query
            .PARAMETER Server
            The Rubrik FQDN or IP address
            .EXAMPLE
            PS> tbd
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0,HelpMessage = 'SLA Domain Name')]
        [ValidateNotNullorEmpty()]
        [String]$name,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$server = $global:RubrikServer
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

        # Validate token and build Base64 Auth string
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($global:RubrikToken+':'))
        $head = @{
            'Authorization' = "Basic $auth"
        }
        
        # Build the URI
        $uri = 'https://'+$server+':443/slaDomain'

        # Submit the request
        $r = Invoke-WebRequest -Uri $uri -Headers $head -Method Get

        # Report the results
        $result = ConvertFrom-Json -InputObject $r.Content 
        if ($name) 
        {
            $result | Where-Object -FilterScript {
                $_.name -match $name
            }
        }
        else 
        {
            $result
        }

    } # End of process
} # End of function