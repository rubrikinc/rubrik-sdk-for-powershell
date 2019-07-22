#Requires -Version 3
function Connect-Rubrik {
    <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a token value for authentication

      .DESCRIPTION
      The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method.
      Rubrik then returns a unique token to represent the user's credentials for subsequent calls.
      Acquire a token before running other Rubrik cmdlets.
      Note that you can pass a username and password or an entire set of credentials.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Connect-Rubrik.html

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin
      This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1.
      The prompt will request a secure password.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
      If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Credential (Get-Credential)
      Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Token "token key provided by Rubrik"
      Rather than passing a username and secure password, you can now generate an API token key in Rubrik. This key can then be used to authenticate instead of a credential or user name and password. 
      
  #>
    [cmdletbinding(SupportsShouldProcess=$true,DefaultParametersetName='UserPassword')]
    Param(
        # The IP or FQDN of any available Rubrik node within the cluster
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullorEmpty()]
        [String]$Server,
        # Username with permissions to connect to the Rubrik cluster
        # Optionally, use the Credential parameter    
        [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 1)]
        [String]$Username,
        # Password for the Username provided
        # Optionally, use the Credential parameter
        [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 2)]
        [SecureString]$Password,
        # Credentials with permission to connect to the Rubrik cluster
        # Optionally, use the Username and Password parameters
        [Parameter(ParameterSetName='Credential',Mandatory=$true, Position = 1)]
        [System.Management.Automation.CredentialAttribute()]$Credential,
        # Provide the Rubrik API Token instead, these are specificially created API token for authentication.
        [Parameter(ParameterSetName='Token',Mandatory=$true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Token,
        #Organization to connect with, assuming the user has multiple organizations
        [Alias('organization_id')]
        [String]$OrganizationID


    )

    Begin {
        
        if (-not (Test-PowerShellSix)) {
            Unblock-SelfSignedCert

            #Force TLS 1.2
            try {
                if ([Net.ServicePointManager]::SecurityProtocol -notlike '*Tls12*') {
                    Write-Verbose -Message 'Adding TLS 1.2'
                    [Net.ServicePointManager]::SecurityProtocol = ([Net.ServicePointManager]::SecurityProtocol).tostring() + ', Tls12'
                }
            }
            catch {
                Write-Verbose -Message $_
                Write-Verbose -Message $_.Exception.InnerException.Message
            }
        }

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name
        
        # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-RubrikAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
  
    }

    Process {

        # Create User Agent string
        $UserAgent = "Rubrik-Powershell-SDK/$($MyInvocation.MyCommand.ScriptBlock.Module.Version.ToString())"
        Write-Verbose -Message "Using User Agent $($UserAgent)"

        if($Token) {
            $head = @{'Authorization' = "Bearer $($Token)";'User-Agent' = $UserAgent}
            Write-Verbose -Message 'Storing all connection details into $global:rubrikConnection'
            $global:rubrikConnection = @{
                id      = $null
                userId  = $null
                token   = $Token
                server  = $Server
                header  = $head
                time    = (Get-Date)
                api     = Get-RubrikAPIVersion -Server $Server
                version = Get-RubrikSoftwareVersion -Server $Server
                authType = 'Token'
            }

            try {
                $RestSplat = @{
                    Endpoint = 'user/me'
                    Method = 'get'
                    Api = 'internal'
                }
                $global:rubrikConnection.userid = (Invoke-RubrikRESTCall @RestSplat -ErrorAction Stop).id -replace '.*?:::'

            } catch {
                Write-Verbose -Message 'Removing API token from $RubrikConnection using Disconnect-Rubrik'
                Disconnect-Rubrik
                throw 'Invalid API Token provided, please provide correct token'
            }
        } else {
            $Credential = Test-RubrikCredential -Username $Username -Password $Password -Credential $Credential

            $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
            $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
            $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    

            # Standard Basic Auth Base64 encoded header with username:password
            $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
            $head = @{
                'Authorization' = "Basic $auth"
                'User-Agent' = $UserAgent
            }          
            $content = Submit-Request -uri $uri -header $head -method $($resources.Method)

            # Final throw for when all versions of the API have failed
            if ($content.token -eq $null) {
                throw 'No token found. Unable to connect with any available API version. Check $Error for details or use the -Verbose parameter.'
            }

            # For API version v1 or greater, use Bearer and token
            $head = @{'Authorization' = "Bearer $($content.token)";'User-Agent' = $UserAgent}

            Write-Verbose -Message 'Storing all connection details into $global:rubrikConnection'
            $global:rubrikConnection = @{
                id      = $content.id
                userId  = $content.userId
                token   = $content.token
                server  = $Server
                header  = $head
                time    = (Get-Date)
                api     = Get-RubrikAPIVersion -Server $Server
                version = Get-RubrikSoftwareVersion -Server $Server
                authType = 'Basic'
            }
        }
        Write-Verbose -Message 'Adding connection details into the $global:RubrikConnections array'
        [array]$global:RubrikConnections += $rubrikConnection
    
        $global:rubrikConnection.GetEnumerator() | Where-Object -FilterScript {
            $_.name -notmatch 'token'
        }

    } # End of process
} # End of function