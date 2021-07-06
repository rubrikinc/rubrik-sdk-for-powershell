#requires -Version 3
function Get-RubrikVgfClusterStorage
{
<#
  .SYNOPSIS
  Returns cluster free space in the case of Volume Group format upgrade

  .DESCRIPTION
  The Get-RubrikVgfClusterStorage cmdlet is used to return projected space consumption
  on any number of volume groups if they are migrated to use the new format, and the
  cluster free space before and after the migration. If no Volume Group ID or list of
  ID is given, it will report the projected space consumption of migrating all Volume
  Groups that are currently using the old format.

  .NOTES
  Written by Feng Lu for community usage
  github: fenglu42

  .LINK
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfclusterstorage

  .EXAMPLE
  Get-RubrikVgfClusterStorage -VGList VolumeGroup:::e0a04776-ab8e-45d4-8501-8da658221d74, VolumeGroup:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322

  This will return projected space consumption on volume groups within the given Volume Group ID list, and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage

  This will return projected space consumption of migrating all old-format volume groups on the Rubrik cluster, and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage -Hostname 'Server1'

  This will return projected space consumption of migrating all old-format volume groups from host "Server1", and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage -Hostname 'Server1' -SLA Gold

  This will return projected space consumption of migrating all old-format volume groups of "Server1" that are protected by the Gold SLA Domain, and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage -Relic

  This will return projected space consumption of migrating all old-format, removed volume groups that were formerly protected by Rubrik, and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage -FailedLastSnapshot

  This will return projected space consumption of migrating all old-format volume groups that needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format, and cluster free space before and after migration.

  .EXAMPLE
  Get-RubrikVgfClusterStorage -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
  
  This will return projected space consumption for the specified VolumeGroup ID, and 0 if this Volume Group uses fast VHDX format (no need for migration).
#>

  [CmdletBinding()]
  Param(
    # Name of the volume group
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('VolumeGroup')]
    [String]$name,
    # List of Volume Group IDs
    [String[]]$VGList,
    # Prefix of Volume Group names
    [String]$NamePrefix,
    # Filter results by hostname
    [String]$hostname,
    # Prefix of host names
    [String]$HostnamePrefix,
    # Filter results to include only relic (removed) volume groups
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the volume group
    [String]$SLA,
    # Filter the report information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Volume group id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # Filter the report based on whether a Volume Group needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format.
    [Alias('NeedsMigration')]
    [Switch]$FailedLastSnapshot,
    # Filter the report based on whether a Volume Group is set to take a full snapshot on the next backup.
    [Alias('ForceFull')]
    [Switch]$SetToUpgrade,
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
    $function = "Get-RubrikVolumeGroup"
    $function1 = "Get-RubrikClusterStorage"

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"

    Write-Verbose -Message "Gather API Data for $function1"
    $resources1 = Get-RubrikAPIData -endpoint $function1
    Write-Verbose -Message "Load API data for $($resources1.Function)"
    Write-Verbose -Message "Description: $($resources1.Description)"
  }

  Process {

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    #get Volume Groups
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    $vgfreport = @()

    foreach ($vg in $result) {
      if ($VGList -and (!$VGList.Contains($vg.id))) {
        continue
      }
      $vgf = $vg | Get-RubrikSnapshot -Latest | Select-Object VolumeGroupId, UsedFastVhdx, FileSizeInBytes
      # Add the report only if the Volume Group did not use fast VHDX format for its latest snapshot
      if (-not $vgf.usedFastVhdx) {
        $vgf | Add-Member NoteProperty VolumeGroupName $vg.name
        $vgf | Add-Member NoteProperty HostName $vg.hostname
        $vgf | Add-Member NoteProperty FailedLastSnapshot $vg.needsMigration
        $vgf | Add-Member NoteProperty SetToUpgrade $vg.forceFull
        $vgfreport += @($vgf)
      }
    }

    if ($NamePrefix) {
      Write-Verbose "Filtering by Volume Group name prefix: $NamePrefix"
      $vgfreport = $vgfreport | Where-Object {$_.VolumeGroupName -Like "$NamePrefix*"}
    }

    if ($HostnamePrefix) {
      Write-Verbose "Filtering by host name prefix: $HostnamePrefix"
      $vgfreport = $vgfreport | Where-Object {$_.HostName -Like "$HostnamePrefix*"}
    }

    if ($FailedLastSnapshot) {
      Write-Verbose "Filtering by whether a Volume Group needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format"
      $vgfreport = $vgfreport | Where-Object {$_.FailedLastSnapshot}
    }

    if ($SetToUpgrade) {
      Write-Verbose "Filtering by whether a Volume Group is set to take a full snapshot on the next backup"
      $vgfreport = $vgfreport | Where-Object {$_.SetToUpgrade}
    }

    $vgids = @()
    $projectedSize = [pscustomobject]@{
      ProjectedAdditionalSpaceUsage=0
      ClusterAvailableSpaceBeforeMigration=0
      ClusterAvailableSpaceAfterMigration=0
      ClusterTotalUsableSpace=0
      VolumeGroupsToMigrate=0
    }

    foreach ($report in $vgfreport) {
      $projectedSize.ProjectedAdditionalSpaceUsage += $report.fileSizeInBytes
      $vgids += $report.VolumeGroupId
    }
    $projectedSize.volumeGroupsToMigrate = $vgids.Count

    Write-Verbose "Calculating space requirement for Volume Groups: $vgids"

    #get cluster storage
    $key = "StorageOverview"
    $uri1 = New-URIString -server $Server -endpoint $Resources1.URI[$key]
    $result1 = Submit-Request -uri $uri1 -header $Header -method $($resources1.Method) -body $body

    $projectedSize.ClusterTotalUsableSpace = $result1.total
    $projectedSize.ClusterAvailableSpaceBeforeMigration = $result1.available
    $projectedSize.ClusterAvailableSpaceAfterMigration = $result1.available - $projectedSize.ProjectedAdditionalSpaceUsage

    return $projectedSize
  } # End of process
} # End of function
