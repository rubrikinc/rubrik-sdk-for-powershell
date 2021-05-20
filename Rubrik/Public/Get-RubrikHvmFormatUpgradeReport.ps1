#requires -Version 3
function Get-RubrikHvmFormatUpgradeReport
{
  <#
      .SYNOPSIS
      Returns projected space consumption of Hyper-V Virtual Machine format upgrade

      .DESCRIPTION
      The Get-RubrikHvmFormatUpgradeReport cmdlet is used to return the projected space consumption on any number of Hyper-V Virtual Machines if they are migrated to use the new format.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatupgradereport

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
      This will return projected space consumption on Hyper-V Virtual Machines within the given Hyper-V Virtual Machine ID list.

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport
      This will return projected space consumption on all Hyper-V Virtual Machines on the Rubrik cluster.

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -Hostname 'Server1'
      This will return projected space consumption on all Hyper-V Virtual Machines from host "Server1".

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -Hostname 'Server1' -SLA Gold
      This will return projected space consumption on all Hyper-V Virtual Machines of "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -Relic
      This will return projected space consumption on all removed Hyper-V Virtual Machines that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -UsedFastVhdx $false
      This will return projected space consumption on Hyper-V Virtual Machines that did not use fast VHDX format in the latest snapshot.

      .EXAMPLE
      Get-RubrikHvmFormatUpgradeReport -Id HypervVirtualMachine:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
      This will return projected space consumption for the specified HypervVirtualMachine ID
  #>

  [CmdletBinding()]
  Param(
    # Name of the Hyper-V Virtual Machine
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('HypervVirtualMachine')]
    [String]$name,
    # List of Hyper-V Virtual Machine IDs
    [String[]]$VMList,
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
    [Boolean]$UsedFastVhdx,
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
      if ($VMList -and (!$VMList.Contains($vm.id))) {
        continue
      }
      $hvmFormat = $vm | Get-RubrikSnapshot -Latest | Select UsedFastVhdx, fileSizeInBytes
      $hvmformat | Add-Member NoteProperty VmId $vm.ID
      # Add the report only if the Hyper-V Virtual Machine did not use fast VHDX format for its latest snapshot
      if (!$hvmFormat.usedFastVhdx) {
        $hvmFormat | Add-Member NoteProperty VmName $vm.name
        foreach ($host in $hostResult) {
          $vmHostId = -join ("HypervServer:::", $vm.HostId)
          if($host.data.id -eq $vmHostId) {
            $hvmformat | Add-Member NoteProperty HostName $host.data.name
            $hvmformat | Add-Member NoteProperty HostId $host.data.Id
            break
          }
        }

        $hvmformatreport += @($hvmFormat)
      }
    }

    if ($NamePrefix) {
      Write-Verbose "Filtering by Hyper-V Virtual Machine name prefix: $NamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.VmName -Like "$NamePrefix*"}
    }

    if ($HostnamePrefix) {
      Write-Verbose "Filtering by host name prefix: $HostnamePrefix"
      $hvmformatreport = $hvmformatreport | Where {$_.HostName -Like "$HostnamePrefix*"}
    }

    if ($hostname) {
      Write-Verbose "Filtering by host name: $hostname"
      $hvmformatreport = $hvmformatreport | Where {$_.HostName -eq $hostname}
    }

    if ($PSBoundParameters.ContainsKey('UsedFastVhdx')) {
      Write-Verbose "Filtering by UsedFastVhdx flag: $UsedFastVhdx"
      $hvmformatreport = $hvmformatreport | Where {$_.UsedFastVhdx -eq $UsedFastVhdx}
    }

    $resultMap = @()
    $totalSize = 0
    foreach ($report in $hvmformatreport) {
      $object = New-Object PSObject
      $object | Add-Member NoteProperty VmName $report.VmName
      $object | Add-Member NoteProperty VmId $report.VmId
      $object | Add-Member NoteProperty ProjectedSpaceConsumptionInBytes $report.fileSizeInBytes
      $resultMap += $object
      $totalSize += $report.fileSizeInBytes
    }
    $object = New-Object PSObject -Property @{VmName="AllHypervVirtualMachines"; VmId="AllHypervVirtualMachines"; ProjectedSpaceConsumptionInBytes=$totalSize}
    $resultMap += $object

    return $resultMap
  } # End of process
} # End of function