#Requires -Version 3
function Restore-RubrikVApp
{
  <#  
      .SYNOPSIS
      Restores a given snapshot for a vCD vApp
      
      .DESCRIPTION
      The Restore-RubrikVApp cmdlet is used to restore a snapshot from a protected vCD vApp. The existing vApp will be marked as 'deprecated' if it exists at the time of restore.
      
      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/restore-rubrikvapp

      .EXAMPLE
      Restore-RubrikVApp -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -PowerOn
      This restores the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b
      
      .EXAMPLE
      (Get-RubrikVApp 'vApp01' -PrimaryClusterID local | Get-RubrikSnapshot -Latest).id | Restore-RubrikVApp -PowerOn
      This retreives the latest snapshot from the given vApp 'vApp01' and restores it

      .EXAMPLE
      $id = (Get-RubrikVApp -Name "vApp01" -PrimaryClusterID local | Get-RubrikSnapshot -Latest ).id
      $recoveropts = Get-RubrikVAppRecoverOption -Id $id
      $restorableVms = $recoveropts.restorableVms
      $vm = @()
      $vm += $restorableVms[0]
      Restore-RubrikVApp -id $id -Partial $vm
      This retreives the latest snapshot from the given vApp 'vApp01' and performs a partial restore on the first VM in the vApp.
      This is an advanced use case and the user is responsible for parsing the output from Get-RubrikVAppRecoverOption.
      Syntax of the object passed with the -Partial Parameter must match the format of the object returned from (Get-RubrikVAppRecoverOption).restorableVms
#>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the vApp snapshot to restore
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Full')]
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Partial')]
    [ValidateNotNullOrEmpty()]
    [Alias('snapshot_id')]
    [String]$id,
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
    if($PowerOn.IsPresent) {
        $resources.Body.shouldPowerOnVmsAfterRecovery = $true
    } else {
        $resources.Body.shouldPowerOnVmsAfterRecovery = $false
    }

    if($Partial) {
        Write-Verbose -Message "Performing Partial vApp Recovery"
        $resources.Body.vmsToRestore = @()
        $resources.Body.vmsToRestore += $Partial

        $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
        Write-Verbose -Message "REST Body $($body)"
    } else {
        Write-Verbose -Message "Performing Full vApp Recovery"
        $recoveropts = Get-RubrikVAppRecoverOption -id $id
        $resources.Body.vmsToRestore = $recoveropts.restorableVms

        if($DisableNetwork) {
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    $network.isConnected = $false
                    Write-Verbose -Message "Disabled NIC $($network.nicIndex) on $($vm.Name)"
                }
            }
        }

        if($NoMapping) {
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    Write-Verbose -Message "Unmapping $($network.vappNetworkName) from $($vm.Name)"
                    $network.PSObject.Properties.Remove('vappNetworkName')
                }
            }
        }

        if($RemoveNetworkDevices) {
            foreach($vm in $resources.Body.vmsToRestore) {
                $vm.networkConnections = @()
            }
            Write-Verbose -Message "Removed all NICs from vApp"
        }

        if($NetworkMapping) {
            # Check RubrikVAppRecoverOption to verify
            $found = $false
            Write-Verbose -Message "Validating $($NetworkMapping) network"
            foreach($network in $recoveropts.availableVappNetworks) {
                if($network.name -eq $NetworkMapping) {
                    $found = $true
                    Write-Verbose -Message "Validated $($NetworkMapping) network"
                }
            }
            if($false -eq $found) {
                throw "$($NetworkMapping) is not a valid network for this vApp. Please supply a valid network."
            }
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    Write-Verbose -Message "Mapping NIC $($network.nicIndex) to $($NetworkMapping) network"
                    $network.vappNetworkName = $NetworkMapping
                }
            }
        }

        $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
        Write-Verbose -Message "REST Body $($body)"
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    # $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function