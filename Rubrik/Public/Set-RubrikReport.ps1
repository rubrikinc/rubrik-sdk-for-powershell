#requires -Version 3
function Set-RubrikReport
{
  <#
      .SYNOPSIS
      Change report settings by taking an existing report and making the desired changes

      .DESCRIPTION
      The Set-RubrikReport cmdlet is used to change settings on an existing report by specifying one or more parameters to make these changes. Currently it is supported to change the new and the colums displayed in the table.

      .NOTES
      Written by Jaap Brasser for community usage
      Twitter: @jaap_brasser
      GitHub: jaapbrasser
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikreport

      .EXAMPLE
      Get-RubrikReport -Name 'Boring Report' | Set-RubrikReport -NewName 'Quokka Report'

      This will rename the report named 'Boring Report' to 'Quokka Report'

      .EXAMPLE
      Get-RubrikReport -Name 'Quokka Report' | Set-RubrikReport -NewTableColumns TaskStatus, TaskType, ObjectName, ObjectType, Location, SlaDomain, StartTime, EndTime, Duration, DataTransferred, DataStored, DedupRatioForJob

      This will change the table colums in 'Quokka Report' to the specified values in the -NewTableColums parameter
  #>

  [CmdletBinding()]
  Param(
    # The ID of the report.
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [String]$id,
    # The new name of the report
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [String]$Name,
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    $chart0,
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    $chart1,
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    $filters,
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    $table,
    [string] $NewName,
    [ValidateSet('Hour', 'Day', 'Month', 'Quarter', 'Year', 'SlaDomain', 'ReplicationTarget', 'ArchivalTarget', 'TaskStatus', 'TaskType', 'Location', 'ObjectName', 'ObjectType', 'ObjectIndexType', 'ClusterLocation', 'ComplianceStatus', 'Organization', 'RecoveryPoint', 'RecoveryPointType', 'Username', 'FailureReason', 'SnapshotConsistency', 'QueuedTime', 'StartTime', 'EndTime', 'Duration', 'DataTransferred', 'LogicalDataProtected', 'DataStored', 'NumFilesTransferred', 'EffectiveThroughput', 'DedupRatio', 'LogicalDedupRatio', 'DataReductionPercent', 'LogicalDataReductionPercent', 'TaskCount', 'SuccessfulTaskCount', 'CanceledTaskCount', 'FailedTaskCount', 'AverageDuration', 'ObjectCount', 'TotalLocalStorage', 'TotalReplicaStorage', 'TotalArchiveStorage', 'LocalStorageGrowth', 'ArchiveStorageGrowth', 'ReplicaStorageGrowth', 'ProtectedOn', 'InComplianceCount', 'NonComplianceCount', 'ArchivalInComplianceCount', 'ArchivalNonComplianceCount', 'TotalSnapshots', 'MissedLocalSnapshots', 'MissedArchivalSnapshots', 'LocalSnapshots', 'ReplicaSnapshots', 'ArchiveSnapshots', 'LatestLocalSnapshot', 'LocalCdpStatus', 'PercentLocal24HourCdpHealthy', 'LocalCdpLogStorage', 'LocalCdpThroughput', 'LatestLocalSnapshotIndexState', 'LocalIndexedSnapshotsCount', 'LocalUnindexedSnapshotsCount', 'LocalPendingForIndexSnapshotsCount', 'LatestLocalIndexedSnapshotTime', 'CdpReplicationStatus', IgnoreCase = $false)]
    [string[]]$NewTableColumns,
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
    # Build body object
    $CurrentBody = [pscustomobject]@{
      name = $Name
      filters = $filters
      chart0 = $chart0
      chart1 = $chart1
      table = $table
    }

    switch ($true) {
      {$NewName} {$CurrentBody.Name = $NewName}
      {$NewTableColumns} {$CurrentBody.table.columns = $NewTableColumns}
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = $CurrentBody | ConvertTo-Json -Depth 10
    Write-Verbose -Message "Body = $body"
    if ($NewName -or $NewTableColumns) {
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    } else {
      Write-Warning ('No new values submitted, no changes made to report: {0} ({1})' -f $Name, $id)
    }
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result
  } # End of process
} # End of function