#requires -Version 3
function Remove-RubrikAPIToken
{
  <#
      .SYNOPSIS
      Removes a Rubrik API Token.

      .DESCRIPTION
      The Remove-RubrikAPIToken cmdlet is used to remove an API Token from the Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikAPIToken.html

      .EXAMPLE
      Remove-RubrikAPIToken -TokenId "11111111-2222-3333-4444-555555555555"
      This will remove the API Token matching id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Remove-RubrikAPIToken -TokenId ("11111111-2222-3333-4444-555555555555","aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
      This will remove the API Tokens matching id values "11111111-2222-3333-4444-555555555555" and "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" in one request.

  #>

  [CmdletBinding()]
  Param(
    # API Token ID value(s). For multiple ID values, encase the values in parenthesis and separate each ID with a comma. See the examples for more details.
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('tokenIds')]
    [Array]$TokenId,
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