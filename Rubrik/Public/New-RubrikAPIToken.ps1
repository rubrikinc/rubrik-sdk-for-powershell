#requires -Version 3
function New-RubrikAPIToken
{
  <#
      .SYNOPSIS
      Creates a new Rubrik API Token.

      .DESCRIPTION
      xxxThe New-RubrikHost cmdlet is used to register a host with the Rubrik cluster. This could be a host leveraging the Rubrik Backup Service or directly as with the case of NAS shares.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikAPIToken.html

      .EXAMPLE
      New-RubrikAPIToken
      This will generate a new API Token named "API Token" that lasts for 60 minutes (1 hour).

      .EXAMPLE
      New-RubrikAPIToken -Expiration 2880 -Tag "2-Day Token"
      This will generate a new API Token named "2-Day Token" that lasts for 2880 minutes (48 hours / 2 days).

      .EXAMPLE
      New-RubrikAPIToken -Expiration 10080 -Tag "Dev Org Weekly Token" -OrganizationId "Organization:::11111111-2222-3333-4444-555555555555"
      This will generate a new API Token named "Dev Org Weekly Token" that lasts for 10080 minutes (7 days) in the organization matching id value "Organization:::11111111-2222-3333-4444-555555555555".
      This assumes that the current session that is requested the token has authority in that organization.
  #>

  [CmdletBinding()]
  Param(
    # Bind the new session to the specified organization. When this parameter is not specified, the session will be bound to an organization chosen according to the user's preferences and authorizations.
    [String]$OrganizationId,
    # This value specifies an interval in minutes. The token expires at the end of the interval. By default, this value is 60 (1 hour). This value cannot exceed 525600 (365 days).
    [ValidateRange(1,525600)]
    [Int]$Expiration = 60,
    # Name assigned to the token. The default value is "API Token".
    [Alias("Name")]
    [String]$Tag,
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

    #region one-off
    # Because this payload has 2-layers of nested body objects, the body is written out here as of 5.0 CDM.
    $body = @{
      initParams = @{
        apiToken = @{
          expiration = $Expiration
        }
      }
    }
    # The Organization ID is an optional param and takes on the default org of the calling session if left empty. Sending over null is not valid.
    if ($OrganizationId) {$body.initParams.Add("organizationId", $OrganizationId)}
    # The Tag is an optional param and takes on the value of "API Token" if nothing is supplied.
    if ($Tag) {$body.initParams.apiToken.Add("tag", $Tag)}
    $body = ConvertTo-Json -InputObject $body
    Write-Verbose -Message "Body = $body"
    #endregion

    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function