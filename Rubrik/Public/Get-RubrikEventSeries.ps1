#requires -Version 3
function Get-RubrikEventSeries
{
  <#
      .SYNOPSIS
      Retrieve information for events grouped by event series

      .DESCRIPTION
      The Get-RubrikEventSeries cmdlet is used to pull a event data from a event series within a Rubrik cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikeventseries

      .EXAMPLE
      Get-RubrikEventSeries
      This will query for all of the events belonging to event series in the Rubrik Cluster

      .EXAMPLE
      Get-RubrikEventSeries -id '1111-2222-3333'
      This will query for all of the events belonging to the specified event series in the Rubrik Cluster

      .EXAMPLE
      Get-RubrikEventSeries -Status 'Failure'
      This will query for all of the failed events belonging to event series in the Rubrik Cluster

      .EXAMPLE
      Get-RubrikEventSeries -EventType 'Backup'
      This will query for all of the backup events belonging to event series in the Rubrik Cluster
  #>

  [CmdletBinding()]
  Param(
    # Filter by Event Series ID
    [parameter()]
    [string]$Id,
    # Filter by Status. Enter any of the following values: 'Failure', 'Warning', 'Running', 'Success', 'Canceled', 'Cancelingâ€™.
    [ValidateSet('Failure', 'Success', 'Queued', 'Active', IgnoreCase = $false)]
    [parameter()]
    [string]$Status,
    # Filter by Event Type.
    [ValidateSet('Archive', 'Backup', 'Instantiate', 'Recovery', 'Replication', IgnoreCase = $false)]
    [Alias('event_type')]
    [parameter()]
    [string]$EventType,
    # Filter by a comma separated list of object IDs.
    [Alias('object_ids')]
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [array]$objectIds,
    # Filter all the events according to the provided name using infix search for resources and exact search for usernames.
    [Alias('object_name')]
    [parameter()]
    [string]$ObjectName,
    # Filter all the events by object type. Enter any of the following values: 'VmwareVm', 'Mssql', 'LinuxFileset', 'WindowsFileset', 'WindowsHost', 'LinuxHost', 'StorageArrayVolumeGroup', 'VolumeGroup', 'NutanixVm', 'Oracle', 'AwsAccount', and 'Ec2Instance'. WindowsHost maps to both WindowsFileset and VolumeGroup, while LinuxHost maps to LinuxFileset and StorageArrayVolumeGroup.
    [Alias('object_type')]
    [parameter()]
    [string]$ObjectType,
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

    return $result

  } # End of process
} # End of function