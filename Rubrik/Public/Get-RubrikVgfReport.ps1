#requires -Version 3
function Get-RubrikVgfReport
{
  <#
      .SYNOPSIS
      Retrieves backup format report on one or more volume groups known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVgfReport cmdlet is used to pull the backup format report from a Rubrik cluster on any number of volume groups.

      .NOTES
      Written by Feng Lu for community usage
      github: fenglu42

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfreport

      .EXAMPLE
      Get-RubrikVgfReport -Hostname 'Server1'

      This will return backup format report on all volume groups from host "Server1".

      .EXAMPLE
      Get-RubrikVgfReport -Hostname 'Server1' -SLA Gold

      This will return backup format report on all volume groups of "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVgfReport -Relic

      This will return backup format report on all removed volume groups that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikVgfReport -FailedLastSnapshot

      This will return backup format report on all volume groups that needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format.

      .EXAMPLE
      Get-RubrikVgfReport -UsedFastVhdx false

      This will return backup format report on volume groups that did not use fast VHDX format in the latest snapshot.

      .EXAMPLE
      Get-RubrikVgfReport -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
      
      This will return backup format report for the specified VolumeGroup ID
  #>

  [CmdletBinding()]
  Param(
    # Name of the volume group
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('VolumeGroup')]
    [String]$name,
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
    # Filter the report based on whether the Volume Group used fast VHDX format for its latest snapshot.
    [String]$LatestSnapshotFormat,
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

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  }

  Process {

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    $vgfreport = @()

    foreach ($vg in $result) {
      $vgsnapshot = Get-RubrikSnapshot -Latest -id $vg.ID | Select-Object VolumeGroupId, usedFastVhdx
      if (!$vgsnapshot) {
        continue
      }
      $vgf = $vgsnapshot | Select-Object@{N='ID'; E={$_.VolumeGroupId}}, @{N='Migrated'; E={$_.usedFastVhdx}}
      $vgf | Add-Member NoteProperty Name $vg.name
      $vgf | Add-Member NoteProperty SLADomain $vg.configuredSlaDomainName
      $vgf | Add-Member NoteProperty HostName $vg.hostname
      $vgf | Add-Member NoteProperty FailedLastSnapshot $vg.needsMigration
      $vgf | Add-Member NoteProperty SetToUpgrade $vg.forceFull

      $vgfreport += @($vgf)
    }

    if ($NamePrefix) {
      Write-Verbose "Filtering by Volume Group name prefix: $NamePrefix"
      $vgfreport = $vgfreport | Where-Object {$_.Name -Like "$NamePrefix*"}
    }

    if ($HostnamePrefix) {
      Write-Verbose "Filtering by host name prefix: $HostnamePrefix"
      $vgfreport = $vgfreport | Where-Object {$_.HostName -Like "$HostnamePrefix*"}
    }

    if ($LatestSnapshotFormat) {
      Write-Verbose "Filtering by latest snapshot format: $LatestSnapshotFormat"
    }
    if ($LatestSnapshotFormat -eq "fastvhdx") {
      $vgfreport = $vgfreport | Where-Object {$_.Migrated}
    } elseif ($LatestSnapshotFormat -eq "smb") {
      $vgfreport = $vgfreport | Where-Object {!$_.Migrated}
    }

    if ($FailedLastSnapshot) {
      Write-Verbose "Filtering by whether a Volume Group needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format"
      $vgfreport = $vgfreport | Where-Object {$_.FailedLastSnapshot}
    }

    if ($SetToUpgrade) {
      Write-Verbose "Filtering by whether a Volume Group is set to take a full snapshot on the next backup"
      $vgfreport = $vgfreport | Where-Object {$_.SetToUpgrade}
    }

    return $vgfreport
  } # End of process
} # End of function
