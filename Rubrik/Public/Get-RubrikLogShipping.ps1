#requires -Version 3
function Get-RubrikLogShipping
{
  <#
      .SYNOPSIS
      Retrieves all log shipping configuration objects. Results can be filtered and sorted.

      .DESCRIPTION
      Retrieves all log shipping configuration objects. Results can be filtered and sorted.

      .NOTES
      Written by Chris Lumnah
      Twitter: @lumnah
      GitHub: clumnah
      Any other links you'd like here

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriklogshipping

      .EXAMPLE
      Get-RubrikLogShipping

      Get all log shipping configurations

      .EXAMPLE
      Get-RubrkLogShipping -PrimaryDatabase 'AdventureWorks2014'

      Get all log shipping configurations for the 'AdventureWorks2014' database

      .EXAMPLE
      Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER

      Get all log shipping configurations for a given location (log shipping secondary server)

      .EXAMPLE
      Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER -DetailedObject

      Get all log shipping configurations for a given location (log shipping secondary server) and retrieves detailed information about these objects
  #>

  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,

    [Alias('primary_database_id')]
    [String]$PrimaryDatabaseId,

    [Parameter(
      Position = 0)]
    [Alias('primary_database_name')]
    [String]$PrimaryDatabaseName,

    [Alias('secondary_database_name')]
    [String]$SecondaryDatabaseName,

    #Log Shipping Target Server
    [String]$location,

    [ValidateSet("OK", "Broken", "Initializing", "Stale")]
    [String]$status,

    [String]$limit,

    [String]$offset,

    [ValidateSet("secondaryDatabaseName", "primaryDatabaseName", "lastAppliedPoint", "location")]
    [String]$sort_by,

    [ValidateSet("asc", "desc")]
    [String]$sort_order,

    # DetailedObject will retrieved the detailed LogShipping object, the default behavior of the API is to only retrieve a subset of the full LogShipping object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,

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
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # If the Get-RubrikLogShipping function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResult -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result

  } # End of process
} # End of function