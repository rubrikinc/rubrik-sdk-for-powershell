#requires -Version 3
function Get-RubrikHvmFormatClusterStorage
{
  <#
      .SYNOPSIS
      Returns cluster free space in the case of Hyper-V Virtual Machine format upgrade

      .DESCRIPTION
      The Get-RubrikHvmFormatClusterStorage cmdlet is used to return projected space consumption
      on any number of Hyper-V Virtual Machines if they are migrated to use the new format, and the
      cluster free space before and after the migration. If no Hyper-V Virtual Machine ID or list of
      ID is given, it will report the projected space consumption of migrating all Hyper-V Virtual
      Machines that are currently using the old format.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatclusterstorage

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
      This will return projected space consumption on Hyper-V VMs within the given Hyper-V VMs ID list, and cluster free space before and after migration.

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage
      This will return projected space consumption of migrating all old-format Hyper-V VMs on the Rubrik cluster, and cluster free space before and after migration.

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage -Hostname 'Server1'
      This will return projected space consumption of migrating all old-format Hyper-V VMs from host "Server1", and cluster free space before and after migration.

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage -Hostname 'Server1' -SLA Gold
      This will return projected space consumption of migrating all old-format Hyper-V VMs of "Server1" that are protected by the Gold SLA Domain, and cluster free space before and after migration.

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage -Relic
      This will return projected space consumption of migrating all old-format, removed Hyper-V VMs that were formerly protected by Rubrik, and cluster free space before and after migration.

      .EXAMPLE
      Get-RubrikHvmFormatClusterStorage -Id HypervVirtualMachine:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
      This will return projected space consumption for the specified HypervVirtualMachine ID, and 0 if this HypervVirtualMachine uses fast VHDX format (no need for migration).
  #>

  [CmdletBinding()]
  Param(
    # Name of the HyperV Virtual Machine
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('HypervVM')]
    [String]$name,
    # List of HyperV VM IDs
    [String[]]$VMList,
    # Prefix of HyperV VM names
    [String]$NamePrefix,
    # Filter results by hostname
    [String]$hostname,
    # Prefix of host names
    [String]$HostnamePrefix,
    # Filter results to include only relic (removed) HyperV VMs
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the HyperV VM
    [String]$SLA,
    # Filter the report information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # HyperV VM id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
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
    $function = "Get-RubrikHyperVVM"
    $clusterFunction = "Get-RubrikClusterStorage"
    $hostFunction = "Get-RubrikHyperVHost"

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"

    Write-Verbose -Message "Gather API Data for $clusterFunction"
    $clusterResource = Get-RubrikAPIData -endpoint $clusterFunction
    Write-Verbose -Message "Load API data for $($clusterResource.Function)"
    Write-Verbose -Message "Description: $($clusterResource.Description)"

    Write-Verbose -Message "Gather API Data for $hostFunction"
    $hostResources = Get-RubrikAPIData -endpoint $hostFunction
    Write-Verbose -Message "Load API data for $($hostResources.Function)"
    Write-Verbose -Message "Description: $($hostResources.Description)"
  }

  Process {

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    #get HyperV VMs
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    #get HyperV Hosts
    $hostUri = New-URIString -server $Server -endpoint ($hostResources.URI)
    $hostResult = Submit-Request -uri $hostUri -header $Header -method $($hostResources.Method)

    $hvmformatreport = @()
    foreach ($vm in $result) {
      if ($VMList -and (!$VMList.Contains($vm.id))) {
        continue
      }
      $vmsnapshot = Get-RubrikSnapshot -Latest -id $vm.ID
      if (!$vmsnapshot) {
        continue
      }
      $hvmformat = $vmsnapshot | Select UsedFastVhdx, FileSizeInBytes

      #VM snapshot summary doesn't contain the VM's ID by default.
      $hvmformat | Add-Member NoteProperty VmId $vm.ID

      # Add the report only if the HyperV VM did not use fast VHDX format for its latest snapshot
      if (-not $hvmformat.usedFastVhdx) {
        $hvmformat | Add-Member NoteProperty VmName $vm.name
        foreach ($host in $hostResult) {
          $vmHostId = -join ("HypervServer:::", $vm.HostId)
          if($host.data.id -eq $vmHostId) {
            $hvmformat | Add-Member NoteProperty HostName $host.data.name
            $hvmformat | Add-Member NoteProperty HostId $host.data.Id
            break
          }
        }
        $hvmformatreport += @($hvmformat)
      }
    }
    Write-Output $hvmformatreport

    if ($NamePrefix) {
      Write-Verbose "Filtering by Hyper-V Virtual Machine name prefix: $NamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.VmName -Like "$NamePrefix*"}
    }

    if ($HostnamePrefix) {
      Write-Verbose "Filtering by host name prefix: $HostnamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.HostName -Like "$HostnamePrefix*"}
    }

    #Filter out instead of query because Get-RubrikHyperVVM doesn't take hostname as param
    #TODO - add $hostname as param in parent function to optimise query and we won't need filtering here.
    if ($hostname) {
      Write-Verbose "Filtering by host name: $hostname"
      $hvmformatreport = $hvmformatreport | Where {$_.HostName -eq $hostname}
    }

    $vmids = @()
    $projectedSize = New-Object -TypeName psobject -Property @{
      ProjectedAdditionalSpaceUsage=0;
      ClusterAvailableSpaceBeforeMigration=0;
      ClusterAvailableSpaceAfterMigration=0;
      ClusterTotalUsableSpace=0;
      HypervVmsToMigrate=0
    }
    foreach ($report in $hvmformatreport) {
      $projectedSize.ProjectedAdditionalSpaceUsage += $report.fileSizeInBytes
      $vmids += $report.VmId
    }
    $projectedSize.HypervVmsToMigrate = $vmids.Count

    Write-Verbose "Calculating space requirement for Hyper-V Virtual Machines: $vmids"

    #get cluster storage
    $key = "StorageOverview"
    $clusterUri = New-URIString -server $Server -endpoint $clusterResource.URI[$key]
    $clusterResult = Submit-Request -uri $clusterUri -header $Header -method $($clusterResource.Method) -body $body
    $projectedSize.ClusterTotalUsableSpace = $clusterResult.total
    $projectedSize.ClusterAvailableSpaceBeforeMigration = $clusterResult.available
    $projectedSize.ClusterAvailableSpaceAfterMigration = $clusterResult.available - $projectedSize.ProjectedAdditionalSpaceUsage

    return $projectedSize
  } # End of process
} # End of function
