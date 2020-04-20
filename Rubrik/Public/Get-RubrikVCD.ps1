#Requires -Version 3
function Get-RubrikVCD
{
  <#
      .SYNOPSIS
      Connect to Rubrik and retrieve the current Rubrik vCD settings

      .DESCRIPTION
      The Get-RubrikVCD cmdlet retrieves all vCD settings actively running on the system. This requires authentication.

      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcd

      .EXAMPLE
      Get-RubrikVCD
      This returns the vCD settings on the currently connected Rubrik cluster

      .EXAMPLE
      Get-RubrikVCD -Name 'My vCD Cluster'
      This returns the vCD settings on the currently connected Rubrik cluster matching the name 'My vCD Cluster'

      .EXAMPLE
      Get-RubrikVCD -Hostname 'vcd.example.com'
      This returns the vCD settings on the currently connected Rubrik cluster matching the hostname 'vcd.example.com'

      .EXAMPLE
      Get-RubrikVCD -Status 'Connected'
      This returns the vCD settings on the currently connected Rubrik cluster with the status of 'Connected'

      .EXAMPLE
      Get-RubrikVCD -DetailedObject
      This returns the full set of settings of the vCD clusters on the currently connected Rubrik cluster
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    #ID of the VCD Cluster to retrieve
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # vCD Cluster Name
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # vCD Cluster Hostname
    [ValidateNotNullOrEmpty()]
    [String]$Hostname,
    # vCD Cluster Status
    [ValidateSet('Disconnected', 'Refreshing','Connected','BadlyConfigured','Deleting','Remote')]
    [String]$Status,
    # DetailedObject will retrieved the detailed VCD object, the default behavior of the API is to only retrieve a subset of the full VCD object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
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

    # If the Get-RubrikVCD function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResults -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result

    #return $result

  } # End of process
} # End of function