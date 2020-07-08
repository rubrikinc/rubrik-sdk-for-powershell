#requires -Version 3
function Get-RubrikOrganization
{
  <#
      .SYNOPSIS
      Returns a list of all organizations.

      .DESCRIPTION
      This cmdlet returns all the organizations within Rubrik. Organizations are used to support
      Rubrik's multi-tenancy feature.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikorganization

      .EXAMPLE
      Get-RubrikOrganization
      Returns a complete list of all Rubrik organizations.

      .EXAMPLE
      Get-RubrikOrganization -isGlobal:$false
      Returns a list of non global of all Rubrik organizations.
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Organization ID
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Organization Name
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [String]$name,
    # Filter results on if the org is global or not
    [Alias('is_global')]
    [Switch]$isGlobal,
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
    # If the switch parameter was not explicitly specified remove from query params
    if(-not $PSBoundParameters.ContainsKey('isGlobal')) {
      $Resources.Query.Remove('is_global')
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function