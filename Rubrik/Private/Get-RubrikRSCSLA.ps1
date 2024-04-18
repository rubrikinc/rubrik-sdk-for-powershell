function Get-RubrikRSCSLA {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    Param(
      # Name of the SLA Domain
      [Parameter(
        ParameterSetName='Query',
        Position = 0,
        ValueFromPipelineByPropertyName = $true)]
      [ValidateNotNullOrEmpty()]
      [Alias('SLA')]
      [String]$Name,
      # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
      [Alias('primary_cluster_id')]
      [String]$PrimaryClusterID,
      # SLA Domain id
      [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true)]
      [ValidateNotNullOrEmpty()]
      [String]$id,
      # DetailedObject will retrieved the detailed SLA object, the default behavior of the API is to only retrieve a subset of the full SLA object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
      [Switch]$DetailedObject,
      # Rubrik server IP or FQDN
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='ID')]
      [String]$Server = $global:RubrikConnection.server,
      # API version
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='ID')]
      [String]$api = $global:RubrikConnection.api
    )

    $query = New-RSCQuery -GqlQuery slaDomains
    # Add Fields
    # Shared Types to be reused
    $Duration = New-Object -TypeName RubrikSecurityCloud.Types.Duration
    $Duration.Unit = "HOURS"
    $Duration.DurationField = 24
    $Schedule = New-Object -TypeName RubrikSecurityCloud.Types.BasicSnapshotSchedule
    $Schedule.Retention = 1
    $Schedule.Frequency = 1
    $Schedule.RetentionUnit = "DAYS"
    # ProtectedObjectCount
    $query.field.nodes[1].ProtectedObjectCount = 0
    # Base Frequency
    $query.field.nodes[1].BaseFrequency = $Duration
    # Snapshot Schedule
    $query.field.Nodes[1].SnapshotSchedule = New-Object -TypeName RubrikSecurityCloud.types.SnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.minute = New-Object -TypeName RubrikSecurityCloud.types.minuteSnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.minute.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.hourly = New-Object -TypeName RubrikSecurityCloud.types.hourlySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.hourly.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.daily = New-Object -TypeName RubrikSecurityCloud.types.dailySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.daily.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.weekly = New-Object -TypeName RubrikSecurityCloud.types.WeeklySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.weekly.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.weekly.DayOfWeek = "SUNDAY"
    $query.field.nodes[1].SnapshotSchedule.monthly = New-Object -TypeName RubrikSecurityCloud.types.monthlySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.monthly.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.monthly.DayOfMonth = "FIRST_DAY"
    $query.field.nodes[1].SnapshotSchedule.quarterly = New-Object -TypeName RubrikSecurityCloud.types.quarterlySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.quarterly.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.quarterly.dayOfQuarter = "FIRST_DAY"
    $query.field.nodes[1].SnapshotSchedule.quarterly.quarterStartMonth = "JANUARY"
    $query.field.nodes[1].SnapshotSchedule.yearly = New-Object -TypeName RubrikSecurityCloud.types.YearlySnapshotSchedule
    $query.field.nodes[1].SnapshotSchedule.yearly.BasicSchedule = $Schedule
    $query.field.nodes[1].SnapshotSchedule.yearly.dayOfYear = "FIRST_DAY"
    $query.field.nodes[1].SnapshotSchedule.yearly.yearStartMonth = "JANUARY"
    # Local Retention 
    $query.field.nodes[1].localRetentionLimit = $Duration
    
    if ($PSBoundParameters['Name']) {
      $filter = @{
          "field" = "NAME"
          "text" = "$($Name)"
      }
      $query.var.filter = $filter
      $response = (Invoke-Rsc $query).nodes
      # since there is no exact match
      Write-Verbose -Message "Matching $Name exactly"
      $response = $response | Where-Object {$_.name -eq "$Name"}
    } else {
      #$query = New-RscQuery -GqlQuery slaDomains
      $response = (Invoke-Rsc $query).nodes
    }


  $response = $response | Select-Object -Property *, @{
    Name="isRetentionLocked"; Expression={$_.isRetentionLockedSla}
  },@{
    Name="numProtectedObjects"; Expression={$_.ProtectedObjectCount}
  }
  
  if ($id) {
    $response = $response | where-object {$_.id -eq "$id"}
  }
  return $response

}