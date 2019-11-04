#requires -Version 3
function New-RubrikUser
{
  <#  
      .SYNOPSIS
      Creates a new user

      .DESCRIPTION
      The New-RubrikUser cmdlet is used to create a new user within the Rubrik cluster.
      NOTE: The underlying API endpoints used by this cmdlet are restricted. API token authentication cannot be used with this cmdlet. You must use username/password authentication. 

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikUser

      .EXAMPLE
      New-RubrikUser -Username 'jdoe' -password (ConvertTo-SecureString -String 'secretpassword123!secret' -asplaintext -force)
      This will create a new user with a username of jdoe and the specified password

      .EXAMPLE
      New-RubrikUser -Username 'jdoe' -password (ConvertTo-SecureString -String 'secretpassword123!secret' -asplaintext -force) -FirstName 'John' -LastName 'Doe'
      This will create a new user with a username of jdoe, the specified password, firstname of John, and LastName as Doe
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Username to assign to the created user
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [String]$Username,
    # Password for newly created user
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [SecureString]$Password,
    # Users first name
    [String]$FirstName,
    #Users last name
    [String]$LastName,
    #Users email
    [String]$EmailAddress,
    #Users Contact Number
    [String]$ContactNumber,
    #MFA Server ID associated to user
    [String]$MfaServerId,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
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

    # Convert SecureString password to send to API endpoint as string
    [String]$Password = [String](New-Object PSCredential "user",$Password).GetNetworkCredential().Password
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function