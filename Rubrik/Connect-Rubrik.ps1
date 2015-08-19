#Requires -Version 3
function Connect-Rubrik 
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves a token value for authentication
            .DESCRIPTION
            The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method. Rubrik then returns a unique token to represent the user's credentials for subsequent calls. Acquire a token before running other Rubrik cmdlets.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
            .EXAMPLE
            Connect-Rubrik -Server 192.168.1.1 -Username admin
            This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1. The prompt will request a secure password.
            .EXAMPLE
            Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
            If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Rubrik username')]
        [ValidateNotNullorEmpty()]
        [String]$Username,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'Rubrik password')]
        [ValidateNotNullorEmpty()]
        [SecureString]$Password

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
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password        
        $body = @{
            userId   = $username
            password = $credentials.GetNetworkCredential().Password
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
        Write-Host -Object "Acquired token: $global:RubrikToken`r`nYou are now connected to the Rubrik API."

        # Validate token and build Base64 Auth string
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($global:RubrikToken+':'))
        $global:RubrikHead = @{
            'Authorization' = "Basic $auth"
        }

    } # End of process
} # End of function