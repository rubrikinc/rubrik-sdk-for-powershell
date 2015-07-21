#Requires -Version 3
function Connect-Rubrik 
{
    <#  
            .SYNOPSIS  Connects to Rubrik and retrieves a token value for authentication
            .DESCRIPTION Connects to Rubrik and retrieves a token value for authentication
            .NOTES  Author:  Chris Wahl, chris.wahl@rubrik.com
            .PARAMETER Username
            The Rubrik username
            .PARAMETER Password
            The Rubrik password
            .PARAMETER Server
            The Rubrik FQDN or IP address
            .EXAMPLE
            PS> tbd
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Rubrik username')]
        [ValidateNotNullorEmpty()]
        [String]$username,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Rubrik password')]
        [ValidateNotNullorEmpty()]
        [String]$password,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$server
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

        # Build the URI
        $uri = 'https://'+$server+':443/login'

        # Build the login call JSON
        $body = @{
            userId   = $username
            password = $password
        }

        # Submit the token request
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Method: Post -Body (ConvertTo-Json -InputObject $body)
        }
        catch 
        {
            throw 'Error connecting to Rubrik server'
        }
        $global:RubrikServer = $server
        $global:RubrikToken = (ConvertFrom-Json -InputObject $r.Content).token
        Write-Host -Object "Acquired token: $global:RubrikToken"

    } # End of process
} # End of function