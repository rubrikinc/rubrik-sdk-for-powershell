#Requires -Version 3
function Connect-Rubrik 
{
    <#  
            .SYNOPSIS
            Connects to Rubrik and retrieves a token value for authentication
            .DESCRIPTION
            The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method. Rubrik then returns a unique token to represent the user's credentials for subsequent calls. Acquire a token before running other Rubrik cmdlets. Note that you can pass a username and password or an entire set of credentials.
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
            .EXAMPLE
            Connect-Rubrik -Server 192.168.1.1 -Credentials (Get-Credential)
            Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Rubrik FQDN or IP address')]
        [ValidateNotNullorEmpty()]
        [String]$Server,
        [Parameter(Mandatory = $false,Position = 1,HelpMessage = 'Rubrik username')]
        [String]$Username,
        [Parameter(Mandatory = $false,Position = 2,HelpMessage = 'Rubrik password')]
        [SecureString]$Password,
        [Parameter(Mandatory = $false,Position = 4,HelpMessage = 'Rubrik credentials')]
        [System.Management.Automation.CredentialAttribute()]$Credentials

    )

    Process {

        Write-Verbose -Message 'Validating that login details were passed into username/password or credentials'
        if ($Password -eq $null -and $Credentials -eq $null)
        {
            Write-Warning -Message 'You did not submit a username, password, or credentials.'
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
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

        Write-Verbose -Message 'Build the URI'
        $uri = 'https://'+$Server+':443/login'

        Write-Verbose -Message 'Build the JSON body for Basic Auth'
        if ($Credentials -eq $null)
        {
            $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
        }

        $body = @{
            userId   = $Credentials.UserName
            password = $Credentials.GetNetworkCredential().Password
        }

        Write-Verbose -Message 'Submit the token request'
        try 
        {
            $r = Invoke-WebRequest -Uri $uri -Method: Post -Body (ConvertTo-Json -InputObject $body)
            $content = (ConvertFrom-Json -InputObject $r.Content)
            if ($content.status -ne 'Success')
            {
                throw $content.description
            }
            else 
            {
                $token = (ConvertFrom-Json -InputObject $r.Content).token
                Write-Verbose -Message "Successfully acquired token: $token"
                Write-Host -Object 'You are now connected to the Rubrik API'
            }
        }
        catch 
        {
            throw $_
        }

        Write-Verbose -Message 'Validate token and build Base64 Auth string'
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($token+':'))
        $head = @{
            'Authorization' = "Basic $auth"
        }

        Write-Verbose -Message 'Storing all connection details into $global:RubrikConnection'
        $global:RubrikConnection = @{
            userId = (ConvertFrom-Json -InputObject $r.Content).userId
            token  = $token
            server = $Server
            header = $head
        }
        
        Write-Verbose -Message 'Adding connection details into the $global:RubrikConnections array'
        [array]$global:RubrikConnections += $RubrikConnection

        Write-Verbose -Message 'Storing all connection details into legacy global variables'
        $global:RubrikServer = $Server
        $global:RubrikToken = $token
        $global:RubrikHead = $head

    } # End of process
} # End of function