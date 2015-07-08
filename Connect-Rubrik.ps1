#Requires -Version 4.0

<#  
.SYNOPSIS  Creates a virtual network tier for VMware NSX
.DESCRIPTION Creates a virtual network tier for VMware NSX
.NOTES  Author:  Chris Wahl, @ChrisWahl, WahlNetwork.com
.PARAMETER NSX
	NSX Manager IP or FQDN
.PARAMETER NSXPassword
	NSX Manager credentials with administrative authority
.PARAMETER NSXUsername
	NSX Manager username with administrative authority
.PARAMETER JSONPath
	Path to your JSON configuration file
.PARAMETER vCenter
	vCenter Server IP or FQDN
.PARAMETER NoAskCreds
	Use your current login credentials for vCenter
.EXAMPLE
	PS> Create-NSXTier -NSX nsxmgr.tld -vCenter vcenter.tld -JSONPath "c:\path\prod.json"
#>

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true,Position=0,HelpMessage="NSX Manager IP or FQDN")]
	[ValidateNotNullorEmpty()]
	[String]$NSX,
	[Parameter(Mandatory=$true,Position=1,HelpMessage="NSX Manager credentials with administrative authority")]
	[ValidateNotNullorEmpty()]
	[System.Security.SecureString]$NSXPassword,
	[Parameter(Mandatory=$true,Position=2,HelpMessage="Path to your JSON configuration file")]
	[ValidateNotNullorEmpty()]
	[String]$JSONPath,
	[Parameter(Mandatory=$true,Position=3,HelpMessage="vCenter Server IP or FQDN")]
	[ValidateNotNullorEmpty()]
	[String]$vCenter,
	[String]$NSXUsername = "admin",
	[Parameter(HelpMessage="Use your current login credentials for vCenter")]
	[Switch]$NoAskCreds
	)


# Create NSX authorization string and store in $head
$nsxcreds = New-Object System.Management.Automation.PSCredential "admin",$NSXPassword
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($NSXUsername+":"+$($nsxcreds.GetNetworkCredential().password)))
$head = @{"Authorization"="Basic $auth"}
$uri = "https://$nsx"


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

Invoke-WebRequest -Uri $uri