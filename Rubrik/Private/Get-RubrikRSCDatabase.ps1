function Get-RubrikRSCDatabase {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Rubrik's database id value
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Name of the database
    [Alias('Database')]
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [String]$Name,
    # Filter results to include only relic (removed) databases
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the database instance
    [String]$Instance,
    # Name of the database host
    [String]$Hostname,
    #ServerInstance name (combined hostname\instancename)
    [String]$ServerInstance,
    #SQL InstanceID, used as a unique identifier
    [Alias('instance_id')]
    [string]$InstanceID,
    # Availability Group Name
    [String]$AvailabilityGroupName,
    # SQL AvailabilityGroupID, used as a unique identifier
    [Alias('availability_group_id')]
    [string]$AvailabilityGroupID,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed database object, the default behavior of the API is to only retrieve a subset of the database object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )


  if ($id) {
    $query = New-RscQuery -GqlQuery mssqlDatabase 
    $query.var.fid = "$id"

    # Add extra fields to query
    $PathNode = New-Object -TypeName RubrikSecurityCloud.Types.PathNode
    $PathNode.ObjectType = New-Object -TypeName RubrikSecurityCloud.Types.HierarchyObjectTypeEnum
    $PathNode.Name = "FETCH"
    $Pathnode.Fid = "FETCH"
    $query.field.PhysicalPath = $PathNode

    $query.field.PostBackupScript = "FETCH"
    $query.field.PreBackupScript = "FETCH"
    $query.field.CopyOnly = "FETCH"
    $query.field.HostLogRetention = 0
    $query.field.LogBackupFrequencyInSeconds = 0
    $query.field.LogBackupRetentionInHours = 0

    $response = Invoke-Rsc $query
    return $response
  } else {
    $query = New-RscQuery -GqlQuery mssqlDatabases
    if ($SLA) {
      $sla_id = (Get-RubrikSLA -Name "$SLA").id
      if ($null -ne $sla_id){
        $SLAID = $sla_id
      } else {
        throw "SLA $($sla) cannot be found"
      }
    }

    Write-Verbose -Message "Filtering list by cluster"
    $filter = New-Object System.Collections.ArrayList

    $filter.Add(
      @{
        "field" = "CLUSTER_ID"
        "texts" = "$($global:rubrikConnection.clusterId)"
      }
    ) | Out-Null
    


    if ($Name) {
      $filter.Add(
          @{
            "field" = "NAME_EXACT_MATCH"
            "texts" = "$Name"
          }
        ) | Out-Null
    }
    if ($PSBoundParameters.containsKey("Relic")) {
      if ($Relic -eq $true) {
        $filter.Add(
          @{
            "field" = "IS_RELIC"
            "texts" = "True"
          }
        ) | out-null
      } elseif ($Relic -eq $false) {
        $filter.Add(
          @{
            "field" = "IS_RELIC"
            "texts" = "False"
          }
        ) | out-null
      } 
    }

    if ($SLAID) {
      $filter.Add(
        @{
          "field" = "EFFECTIVE_SLA"
          "texts" = "$SLAID"
        }
      ) | Out-null
    }

    # Add extra fields to query
    $PathNode = New-Object -TypeName RubrikSecurityCloud.Types.PathNode
    $PathNode.ObjectType = New-Object -TypeName RubrikSecurityCloud.Types.HierarchyObjectTypeEnum
    $PathNode.Name = "FETCH"
    $Pathnode.Fid = "FETCH"
    $query.field.nodes[0].PhysicalPath = $PathNode

    $query.field.nodes[0].PostBackupScript = "FETCH"
    $query.field.nodes[0].PreBackupScript = "FETCH"
    $query.field.nodes[0].CopyOnly = "FETCH"
    $query.field.nodes[0].HostLogRetention = 0
    $query.field.nodes[0].LogBackupFrequencyInSeconds = 0
    $query.field.nodes[0].LogBackupRetentionInHours = 0

    Write-Verbose -Message "Adding filter to query"
    $query.var.filter = $filter

    $response = (Invoke-Rsc $query).nodes

    if ($ServerInstance) {
      $Hostname = $ServerInstance.Split("\")[0]
      $Instance = $serverInstance.split("\")[1]
    }

    If ($Hostname) {
      $response = $response | Where-Object { $_.PhysicalPath | Where-Object { $_.ObjectType -eq "PHYSICAL_HOST" -and $_.Name -eq "$Hostname"} }
    }
    If ($Instance) {
      $response = $response | Where-Object { $_.PhysicalPath | Where-Object { $_.ObjectType -eq "MSSQL_INSTANCE" -and $_.Name -eq "$Instance"} }
    }
    if ($InstanceID) {
      $response = $response | Where-Object { $_.PhysicalPath | Where-Object { $_.ObjectType -eq "MSSQL_INSTANCE" -and $_.fid -eq "$InstanceId"} }
    }

  }


  return $response
}