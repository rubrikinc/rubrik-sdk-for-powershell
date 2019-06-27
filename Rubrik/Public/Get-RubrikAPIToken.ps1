#requires -Version 3
function Get-RubrikAPIToken
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of generated API tokens

      .DESCRIPTION
      The Get-RubrikAPIToken cmdlet is used to pull a list of generated API tokens from the Rubrik cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston


      .LINK
     http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIToken.html

      .EXAMPLE
      Get-RubrikAPIToken
      This will return all generated API tokens belonging to the currently logged in user.

      .EXAMPLE
      Get-RubrikAPIToken -tag roxie
      This will return all generated API tokens belonging to the currently logged in user with a 'roxie' tag.

      .EXAMPLE
      Get-RubrikAPIToken -organizationId 1111-2222-3333
      This will return all generated API tokens assigned to the currently logged in user with the specified organization id.
  #>

  [CmdletBinding()]
  Param(
    # UserID to retrieve tokens from - defaults to currently logged in user
    [ValidateNotNullorEmpty()]
    [Alias('user_id')]
    [String]$UserId = $rubrikconnection.userId,
    # Tag assigned to the API Token
    [String]$Tag,
    # Organization ID the API Token belongs to.
    [String]$OrganizationId,
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

    # Remove any api tokens generated for usage with web
    $result = $result | Where-Object {$_.sessionType -ne 'Web'}
    
    return $result

  } # End of process
} # End of function