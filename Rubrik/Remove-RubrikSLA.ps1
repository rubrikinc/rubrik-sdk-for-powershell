#Requires -Version 3
function Remove-RubrikSLA 
{
     <#  
            .SYNOPSIS
            Connects to Rubrik and removes SLA Domains
            .DESCRIPTION
            The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain. The SLA Domain must have zero protected VMs in order to be successful.
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

        Write-Verbose -Message 'Validate the Rubrik token exists'
        if (-not $global:RubrikToken) 
        {
            throw 'You are not connected to a Rubrik server. Use Connect-Rubrik.'
        }

        Write-Verbose -Message 'Gather the Rubrik SLA Domain ID value'
        $slaid = Get-RubrikSLA -SLA $SLA

        Write-Verbose -Message 'Determining if SLA Domain has zero VMs'
        if ($slaid.numVms -ne 0) {throw "SLA Domain has $($slaid.numVms) protected - remove them and retry"}
        
        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$server+':443/slaDomain/'+$($slaid.id)

        Write-Verbose -Message 'Submit the request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Headers $global:RubrikHead -Method Delete
        }
        catch 
        {
            throw $_
        }

    } # End of process
} # End of function