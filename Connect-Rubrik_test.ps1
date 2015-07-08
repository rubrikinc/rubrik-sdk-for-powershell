# Allow untrusted SSL certs
	add-type @"
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
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$uri = 'https://192.168.2.10:443/'

$login_call = @{
  userId = "admin"
  password = "admin"
}

$r = Invoke-WebRequest -Uri ($uri + "login") -Method: Post -Body (ConvertTo-Json $login_call)

$r = Invoke-WebRequest -Uri ($uri + "vm/list") -Method: Get -Headers @{"Authorization"="Basic OWU2MDMyMGMtYzFhYy00ZjkyLTgzZDAtYzk0NGU2ZjlkNjZhOg=="}

$r.Content | ConvertFrom-Json