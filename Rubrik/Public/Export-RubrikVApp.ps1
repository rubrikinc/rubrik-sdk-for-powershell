#Requires -Version 3
function Export-RubrikVApp
{
  <#  
      .SYNOPSIS
      Exports a given snapshot for a vCD vApp
      
      .DESCRIPTION
      The Export-RubrikVApp cmdlet exports a snapshot from a protected vCD vApp.
      
      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvapp

      .EXAMPLE
      Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -PowerOn
      This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in the same Org VDC

     .EXAMPLE
      Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -NoMapping -PowerOn
      This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in the same Org VDC and remove existing network mappings from VM NICs

      .EXAMPLE
      Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -TargetOrgVDCID 'VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567' -PowerOn
      This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in an alternate Org VDC

      .EXAMPLE
      $vapp = Get-RubrikVApp -Name 'vApp01' -PrimaryClusterID local 
      $snapshot = Get-RubrikSnapshot -id $vapp.id -Latest
      $restorableVms = $vapp.vms
      $restorableVms[0].PSObject.Properties.Remove('vcenterVm')
      $vm = @()
      $vm += $restorableVms[0]
      Export-RubrikVApp -id $vapp.id -snapshotid $snapshot.id -Partial $vm -ExportMode ExportToTargetVapp

      This retreives the latest snapshot from the given vApp 'vApp01' and perform a partial export on the first VM in the vApp.
      The VM is exported into the existing parent vApp. Set the ExportMode parameter to 'ExportToNewVapp' parameter to create a new vApp for the partial export.
      This is an advanced use case and the user is responsible for parsing the output from Get-RubrikVApp, or gathering data directly from the API.
      Syntax of the object passed with the -Partial Parameter is available in the API documentation.
#>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the vApp to export
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Full')]
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Partial')]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Rubrik snapshot id of the vApp to export
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Full')]
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Partial')]
    [ValidateNotNullOrEmpty()]
    [Alias('snapshot_id')]
    [String]$snapshotid,
    # Perform a Partial vApp restore. Default operation is a Full vApp restore, unless this parameter is specified.
    [Parameter(Mandatory = $true,ParameterSetName='Partial')]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if ('PSCustomObject' -ne $_.GetType().Name) {
          Throw "Partial parameter should be a PSCustomObject"
        }
        $requiredProperties = @("name","vcdMoid","networkConnections")
        ForEach($item in $requiredProperties) {
            if(!$_.PSObject.Properties.Name.Contains($item)) {
                Throw "Object passed via Partial parameter missing property $($item)"
            }
        }
        return $true
       })]
    [PSCustomObject]$Partial,
    # Specifies whether export should use the existing vApp or create a new vApp. Valid values are ExportToNewVapp or ExportToTargetVapp
    [Parameter(Mandatory = $true)]
    [ValidateSet('ExportToNewVapp','ExportToTargetVapp')]
    [Alias('export_mode')]
    [String]$ExportMode,
    # ID of target vApp for Partial vApp Export. By default the VM(s) will be exported to their existing vApp.
    [Parameter(ParameterSetName='Partial')]
    [String]$TargetVAppID,
    # ID of target Org VDC for Full vApp Export. By default the VM(s) will be exported to their existing Org VDC. /vcd/hierarchy API calls can be used to determine Org VDC IDs.
    [Parameter(ParameterSetName='Full')]
    [String]$TargetOrgVDCID,
    # Disable NICs upon restoration. The NIC(s) will be disabled, but remain mapped to their existing network.
    [Parameter(ParameterSetName='Full')]
    [Switch]$DisableNetwork,
    # Remove network mapping upon restoration. The NIC(s) will not be connected to any existing networks.
    [Parameter(ParameterSetName='Full')]
    [Switch]$NoMapping,
    # Remove network interfaces from the restored vApp virtual machines.
    [Parameter(ParameterSetName='Full')]
    [Switch]$RemoveNetworkDevices,
    # Map all vApp virtual machine NICs to specified network.
    [Parameter(ParameterSetName='Full')]
    [ValidateNotNullOrEmpty()]
    [String]$NetworkMapping,
    # Power on vApp after restoration.
    [Parameter(ParameterSetName='Full')]
    [Parameter(ParameterSetName='Partial')]
    [switch]$PowerOn,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Full')]
    [Parameter(ParameterSetName='Partial')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Full')]
    [Parameter(ParameterSetName='Partial')]
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
    #region oneoff
    $resources.Body.exportMode = $ExportMode
    if($PowerOn.IsPresent) {
        $resources.Body.shouldPowerOnVmsAfterRecovery = $true
    } else {
        $resources.Body.shouldPowerOnVmsAfterRecovery = $false
    }

    if($Partial) {
        Write-Verbose -Message "Performing Partial vApp Recovery"
        $resources.Body.vmsToExport = @()
        $resources.Body.vmsToExport += $Partial

        # Rename vApp VMs and remove unneeded data
        foreach($vm in $resources.Body.vmsToExport) {
            $vm.name = $vm.name + "-" + [string](Get-Date -Format "ddd MMM yyyy HH:mm:ss 'GMT'K")
            Write-Verbose -Message "vApp VM renamed to $($vm.name)"
            $vm.PSObject.Properties.Remove('storagePolicyId')
            # If exporting to a different vApp, unmap network connections
            if($TargetVAppID) { 
                foreach($network in $vm.networkConnections) {
                    Write-Verbose -Message "Unmapping $($network.vappNetworkName) from $($vm.Name)"
                    $network.PSObject.Properties.Remove('vappNetworkName')
                }
            }
        }

        if($ExportMode -eq 'ExportToTargetVapp') {
            Write-Verbose -Message "Performing Partial vApp Export to Existing Target vApp"
            if($TargetVAppID) { 
                $resources.Body.targetVappId = $TargetVAppID
            }
            else 
            { 
                $resources.Body.targetVappId = $id 
            }
            $resources.Body.networksToRestore = @()
            $resources.Body.Remove('newVappParams')

            $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
            Write-Verbose -Message "vApp Export REST Request Body `n$($body)"            
        }
        else {
            Write-Verbose -Message "Performing Partial vApp Export to New vApp"
            $vapp = Get-RubrikVapp -id $id

            # Collect networks to restore
            $networks = [System.Collections.ArrayList]@()
            foreach($vm in $resources.Body.vmsToExport) {
                foreach($network in $vm.networkConnections) {
                    if($false -eq $networks.Contains($network.vappNetworkName)) {
                        $networks.Add($network.vappNetworkName) | Out-Null
                        Write-Verbose -Message "Flagged network $($network.vappNetworkName) for restore"
                    }
                }
            }

            if($TargetOrgVDCID) {
                $orgvdc = $TargetOrgVDCID
            } 
            else {
                # Find orgVdcId from existing vApp
                foreach($item in $vapp.infraPath) {
                    if($item.id.StartsWith('VcdOrgVdc:::')) {
                        $orgvdc = $item.id
                        Write-Verbose -Message "Using Org VDC $($orgvdc) for export"
                    }
                }
            }

            # Build networksToRestore based on networks collected from vApp
            $resources.Body.networksToRestore = [System.Collections.ArrayList]@()
            foreach($availablenet in $vapp.networks) {
                if($networks.Contains($availablenet.name)) {
                    $resources.Body.networksToRestore.Add($availablenet) | Out-Null
                    Write-Verbose -Message "Found network $($availablenet.name) information for restore"
                }
            }

            # Set new vApp name and orgVdcId
            $resources.Body.newVappParams.name = $vapp.name + "-" + [string](Get-Date -Format "ddd MMM yyyy HH:mm:ss 'GMT'K")
            Write-Verbose -Message "Exported vApp will be named $($resources.Body.newVappParams.name)"
            $resources.Body.newVappParams.orgVdcId = $orgvdc

            $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
            Write-Verbose -Message "vApp Export REST Request Body `n$($body)"
        }
    }
    else {
        # Full vApp export is always to a New vApp
        Write-Verbose -Message "Performing Full vApp Export to New vApp"
        $vapp = Get-RubrikVapp -id $id
        
        # Collect networks to restore
        if(-Not $NoMapping -and -Not $RemoveNetworkDevices) {
            $networks = [System.Collections.ArrayList]@()
            foreach($vm in $vapp.vms) {
                foreach($network in $vm.networkConnections) {
                    if($false -eq $networks.Contains($network.vappNetworkName)) {
                        $networks.Add($network.vappNetworkName) | Out-Null
                        Write-Verbose -Message "Flagged network $($network.vappNetworkName) for restore"
                    }
                }
            }
        }

        if($TargetOrgVDCID) {
            $orgvdc = $TargetOrgVDCID
        }
        else {
            # Find orgVdcId from existing vApp
            foreach($item in $vapp.infraPath) {
                if($item.id.StartsWith('VcdOrgVdc:::')) {
                    $orgvdc = $item.id
                    Write-Verbose -Message "Using Org VDC $($orgvdc) for export"
                }
            }
        }

        # Set new vApp name and orgVdcId
        $resources.Body.newVappParams.name = $vapp.name + "-" + [string](Get-Date -Format "ddd MMM yyyy HH:mm:ss 'GMT'K")
        Write-Verbose -Message "Exported vApp will be named $($resources.Body.newVappParams.name)"
        $resources.Body.newVappParams.orgVdcId = $orgvdc
        $resources.Body.vmsToExport = [System.Collections.ArrayList]@()
        foreach($vm in $vapp.vms) {         
            $resources.Body.vmsToExport.Add($vm) | Out-Null
            Write-Verbose -Message "Added $($vm.name) to request"
        }

        # Build networksToRestore based on networks collected from vApp
        if(-Not $NoMapping -and -Not $RemoveNetworkDevices) {
            $resources.Body.networksToRestore = [System.Collections.ArrayList]@()
            foreach($availablenet in $recoveropts.availableVappNetworks) {
                if($networks.Contains($availablenet.name)) {
                    $resources.Body.networksToRestore.Add($availablenet) | Out-Null
                    Write-Verbose -Message "Found network $($availablenet.name) information for restore"
                }
            }
        }

        # Rename vApp VMs and remove unneeded data
        foreach($vm in $resources.Body.vmsToExport) {
            $vm.name = $vm.name + "-" + [string](Get-Date -Format "ddd MMM yyyy HH:mm:ss 'GMT'K")
            Write-Verbose -Message "vApp VM renamed to $($vm.name)"
            $vm.PSObject.Properties.Remove('vcenterVm')
            $vm.PSObject.Properties.Remove('storagePolicyId')
        }

        if($DisableNetwork) {
            foreach($vm in $resources.Body.vmsToExport) {
                foreach($network in $vm.networkConnections) {
                    $network.isConnected = $false
                    Write-Verbose -Message "Disabled NIC $($network.nicIndex) on $($vm.Name)"
                }
            }
        }

        if($NoMapping) {
            $resources.Body.networksToRestore = @()
            foreach($vm in $resources.Body.vmsToExport) {
                foreach($network in $vm.networkConnections) {
                    Write-Verbose -Message "Unmapping $($network.vappNetworkName) from $($vm.Name)"
                    $network.PSObject.Properties.Remove('vappNetworkName')
                }
            }
        }

        if($RemoveNetworkDevices) {
            $resources.Body.networksToRestore = @()
            foreach($vm in $resources.Body.vmsToExport) {
                $vm.networkConnections = @()
            }
            Write-Verbose -Message "Removed all NICs from vApp"
        }

        if($NetworkMapping) {
            foreach($vm in $resources.Body.vmsToExport) {
                foreach($network in $vm.networkConnections) {
                    Write-Verbose -Message "Mapping NIC $($network.nicIndex) to $($NetworkMapping) network"
                    $network.vappNetworkName = $NetworkMapping
                }
            }
        }

        $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
        Write-Verbose -Message "vApp Export REST Request Body `n$($body)"
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $snapshotid
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    # $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function