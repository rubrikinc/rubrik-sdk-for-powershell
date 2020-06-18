#Requires -Version 3
function New-RubrikLDAP
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets Rubrik cluster settings
            
      .DESCRIPTION
      The New-RubrikLDAP cmdlet will set the cluster settings on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikldap
            
      .EXAMPLE
      New-RubrikLDAP -Name "Test LDAP Settings" -baseDN "DC=domain,DC=local" -authServers "192.168.1.8"

      This will create LDAP settings on the Rubrik cluster defined by Connect-Rubrik function

      .EXAMPLE
      $credential = Get-Credential
      New-RubrikLDAP -Name "rubrik.lab" -DynamicDNSName "ad1.test.lab" -BaseDN "DC=rubrik,DC=lab" -BindCredential $Credential -Server "ad1.test.lab" -verbose

      This will create LDAP settings using the credentials object provided as a parameter

      .EXAMPLE
      $SecPw = Read-Host -AsSecureString
      New-RubrikLDAP -Name "rubrik.lab" -DynamicDNSName "ad1.test.lab" -BaseDN "DC=rubrik,DC=lab" -BindUserName jaapjaap -BindUserPassword $SecPw -Server "ad1.test.lab" -verbose

      This will create LDAP settings using the user name and password provided as parameters      
  #>

  [cmdletbinding(SupportsShouldProcess=$true,DefaultParametersetName='UserPassword')]
  Param(
    # Human friendly name
    [Parameter(Mandatory=$True)]
    [string]$Name,
    # Bind credentials with permission to connect to the LDAP server
    # Optionally, use the BindUserName and BindUserPassword parameters
    [Parameter(ParameterSetName='Credential',Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()]$BindCredential,
    # Dynamic DNS name for locating authentication servers.
    [Parameter(Mandatory=$True)]
    [string]$DynamicDNSName,
    # The path to the directory where searches for users begin.
    [string]$BaseDN,
    # An ordered list of authentication servers. Servers on this list have priority over servers discovered using dynamic DNS.
    [array]$AuthServers,
    # Bind username with permissions to connect to the LDAP server
    # Optionally, use the BindCredential parameter    
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 1)]
    [String]$BindUserName,
    # Password for the Username provided
    # Optionally, use the Credential parameter
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 2)]
    [SecureString]$BindUserPassword,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # ID of the Rubrik cluster or me for self
    [String]$id = '',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection

    # Check to ensure that we have credentials for the LDAP server
    $BindCredential = Test-RubrikLDAPCredential -BindUserName $BindUserName -BindUserPassword $BindUserPassword -BindCredential $BindCredential

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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

    #region One-off
    # This section is here to place the LDAP bind credentials into the API request prior to being encrypted and sent to the Rubrik API endpoint
    # Because the New-BodyString private function has already created a JSON payload, we must convert back to a hashtable before updating the credentials
    # Once that's done, we restore the $body var into a proper JSON payload and continue along.
    # See this PR for more information: https://github.com/rubrikinc/rubrik-sdk-for-powershell/pull/263
    Write-Verbose 'Passing $BindCredential username and password into the API request'
    $bodyHash = ConvertFrom-Json $body
    
    if (-not $bodyHash.bindUserName) {
      Add-Member -InputObject $bodyhash -MemberType NoteProperty -Name 'bindUserName' -Value $BindCredential.UserName
    } else {
      $bodyHash.bindUserName = $BindCredential.UserName
    }

    if (-not $bodyHash.bindUserPassword) {
      Add-Member -InputObject $bodyhash -MemberType NoteProperty -Name 'bindUserPassword' -Value $BindCredential.GetNetworkCredential().Password
    } else {
      $bodyHash.bindUserPassword = $BindCredential.GetNetworkCredential().Password
    }

    $body = ConvertTo-Json $bodyHash
    Write-Verbose -Message "Updated Body with credential object = $($body -replace 'bindUserPassword": "(.*?)"','bindUserPassword": "***"')"
    #endregion    

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function