#requires -Version 3
function Get-RubrikHost
{
  <#
      .SYNOPSIS
      Retrieve summary information for all hosts that are registered with a Rubrik cluster.

      .DESCRIPTION
      The Get-RubrikHost cmdlet is used to retrive information on one or more hosts that are being protected with the Rubrik Backup Service or directly as with the case of NAS shares.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhost

      .EXAMPLE
      Get-RubrikHost
      This will return all known hosts

      .EXAMPLE
      Get-RubrikHost -Hostname 'Server1'
      This will return details on any hostname matching "Server1"

      .EXAMPLE
      Get-RubrikHost -Type 'Windows' -PrimaryClusterID 'local'
      This will return details on all Windows hosts that are being protected by the local Rubrik cluster

      .EXAMPLE
      Get-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
      This will return details specifically for the host id matching "Host:::111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikHost -Name myserver01 -DetailedObject
      This will return the Host object with all properties, including additional details such as information around the Volume Filter Driver if applicable. Using this switch parameter may negatively affect performance

      #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Retrieve hosts with a host name matching the provided name. The search type is infix
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [Alias('Hostname')]
    [String]$Name,
    # Filter the summary information based on the operating system type. Accepted values are 'Windows', 'Linux', 'ANY', 'NONE'. Use NONE to only return information for hosts templates that do not have operating system type set. Use ANY to only return information for hosts that have operating system type set.
    [ValidateSet('Windows','Linux','Any','None')]
    [Alias('operating_system_type')]
    [String]$Type,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # ID of the registered host
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
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

    # If the Get-RubrikHost function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResult -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result

  } # End of process
} # End of function