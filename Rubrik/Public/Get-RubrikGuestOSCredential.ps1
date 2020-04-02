#Requires -Version 3
function Get-RubrikGuestOSCredential
{
  <#
      .SYNOPSIS
      Connects to Rubrik and retrieves the Guest OS credentials stored within a cluster

      .DESCRIPTION
      The Get-RubrikGuestOSCredential cmdlet will retrieve information around the Guest OS Credentials stored within a given cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikguestoscredential

      .EXAMPLE
      Get-RubrikGuestOSCredential
      This will return all of the guest os crendentials stored within the currently authenticated cluster

      .EXAMPLE
      Get-RubrikGuestOSCredential -username administrator
      This will return all of the guest os crendentials stored within the currently authenticated cluster with a username of administrator

      .EXAMPLE
      Get-RubrikGuestOSCredential -domain "domain.local"
      This will return all of the guest os crendentials belonging to the domain.local domain stored within the currently authenticated cluster
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # ID of the Guest OS Credential to retrieve
    [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    [Parameter(
      ParameterSetName='Query',
      Mandatory = $true,
      Position = 0)]
    # Username of the Guest OS Crential to retrieve
    [String]$Username,
    # Domain to retrieve Guest OS Credentials from
    [String]$Domain,
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