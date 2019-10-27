function Unblock-SelfSignedCert() {
  <#
    .SYNOPSIS
    Allows the use of self-signed certficates

    .DESCRIPTION
    The Unblock-SelfSignedCert function enables the usage of self-signed certificates for HTTPs connections by loading the approapriate Cerficate Policies
  #>
  
  Write-Verbose -Message 'Allowing self-signed certificates'
    
  if ([System.Net.ServicePointManager]::CertificatePolicy -notlike 'TrustAllCertsPolicy') {
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
  }
}
