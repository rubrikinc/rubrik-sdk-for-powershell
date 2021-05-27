#requires -Version 3
function Get-RubrikHvmFormatReport
{
  <#
      .SYNOPSIS
      Retrieves backup format report on one or more Hyper-V Virtual Machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikHvmFormatReport cmdlet is used to pull the backup format report from a Rubrik cluster on any number of Hyper-V Virtual Machines.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatreport

      .EXAMPLE
      Get-RubrikHvmFormatReport -Hostname 'Server1'
      This will return backup format report on all Hyper-V Virtual Machines from host "Server1".

      .EXAMPLE
      Get-RubrikHvmFormatReport -Hostname 'Server1' -SLA Gold
      This will return backup format report on all Hyper-V Virtual Machines of "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikHvmFormatReport -Relic
      This will return backup format report on all removed Hyper-V Virtual Machines that were formerly protected by Rubrik.

      .EXAMPLE
      LatestSnapshotFormat <smb> OR <fastvhdx>
      Get-RubrikHvmFormatReport -LatestSnapshotFormat fastvhdx
      This will return backup format report on all removed Hyper-V Virtual Machines that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikHvmFormatReport -Id HypervVirtualMachine:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
      This will return backup format report for the specified HypervVirtualMachine ID
  #>

  [CmdletBinding()]
  Param(
    # Name of the Hyper-V Virtual Machine
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('HypervVirtualMachine')]
    [String]$name,
    # Prefix of Hyper-V Virtual Machine names
    [String]$NamePrefix,
    # Filter results by hostname
    [String]$hostname,
    # Prefix of host names
    [String]$HostnamePrefix,
    # Filter results to include only relic (removed) Hyper-V Virtual Machines
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the Hyper-V Virtual Machine
    [String]$SLA,
    # Filter the report information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Hyper-V Virtual Machine id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # Filter the report based on whether the Hyper-V Virtual Machine used fast VHDX format for its latest snapshot.
    [String]$LatestSnapshotFormat,
    # Filter the report based on whether a Hyper-V Virtual Machine is set to take a full snapshot on the next backup.
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
    $function = "Get-RubrikHyperVVM"
    $hostFunction = "Get-RubrikHyperVHost"

    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"

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
      $vmsnapshot = Get-RubrikSnapshot -Latest -id $vm.ID
      if (!$vmsnapshot) {
        continue
      }
      $vmsnapshot | Add-Member NoteProperty VmId $vm.ID
      $hvmformat = $vmsnapshot | Select UsedFastVhdx, FileSizeInBytes
      $hvmformat = $vmsnapshot | Select-Object @{N='ID'; E={$_.VmId}}, @{N='Migrated'; E={$_.usedFastVhdx}}

      $hvmformat | Add-Member NoteProperty VmName $vm.name
      $hvmformat | Add-Member NoteProperty SLADomain $vm.configuredSlaDomainName
      $hvmformat | Add-Member NoteProperty SetToUpgrade $vm.forceFull

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
    if ($NamePrefix) {
      Write-Verbose "Filtering by Hyper-V Virtual Machine name prefix: $NamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.VmName -Like "$NamePrefix*"}
    }

    if ($HostnamePrefix) {
      Write-Verbose "Filtering by host name prefix: $HostnamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.HostName -Like "$HostnamePrefix*"}
    }

    if ($LatestSnapshotFormat) {
      Write-Verbose "Filtering by latest snapshot format: $LatestSnapshotFormat"
      if ($LatestSnapshotFormat -eq "fastvhdx") {
        $hvmformatreport = $hvmformatreport | Where {$_.Migrated}
      } elseif ($LatestSnapshotFormat -eq "smb") {
        $hvmformatreport = $hvmformatreport | Where {!$_.Migrated}
      } else {
        Write-Output "LatestSnapshotFormat must be <smb> or <fastvhdx>"
        $hvmformatreport = @()
      }

    }

    if ($SetToUpgrade) {
      Write-Verbose "Filtering by whether a Hyper-v Virtual Machine is set to take a full snapshot on the next backup"
      $hvmformatreport = $hvmformatreport | Where-Object {$_.SetToUpgrade}
    }

    return $hvmformatreport
  } # End of process
} # End of function
