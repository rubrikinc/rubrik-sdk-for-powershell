#requires -Version 3
function New-RubrikUser
{
  <#  
      .SYNOPSIS
      Creates a new user

      .DESCRIPTION
      The New-RubrikUser cmdlet is used to create a new user within the Rubrik cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikUser.html

      .EXAMPLE
      New-RubrikUser -Name 'Server1.example.com'
      This will register a host that resolves to the name "Server1.example.com"

      .EXAMPLE
      New-RubrikUser -Name 'NAS.example.com' -HasAgent $false
      This will register a host that resolves to the name "NAS.example.com" without using the Rubrik Backup Service
      In this case, the example host is a NAS share.
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
    [String]$MFAServerId,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function