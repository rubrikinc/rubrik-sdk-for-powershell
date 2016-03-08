function Verb-RubrikNoun
{
    <#  
            .SYNOPSIS
            !!!Fill Me In!!!
            .DESCRIPTION
            !!!Fill Me In!!!
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/rubrikinc/PowerShell-Module
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Required variable')]
        [ValidateNotNullorEmpty()]
        [String]$RequiredVar,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Optional variable')]
        [ValidateNotNullorEmpty()]
        [Switch]$OptionalVar,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server = $global:RubrikServer
    )

    Process {

        Write-Verbose -Message 'Validate the Rubrik token exists'
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        Write-Verbose -Message 'Allow untrusted SSL certs'
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

        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$Server+':443/!!!'

        Write-Verbose -Message 'Build the body'
        $body = @{
        !!!
        }

        Write-Verbose -Message 'Submit the request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Post -Body (ConvertTo-Json -InputObject $body)
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function