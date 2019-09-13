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
      Github: shamsway
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Restore-RubrikVApp -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b'
      This will restore the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b
      
      .EXAMPLE
      (Get-RubrikVApp 'vApp01' -PrimaryClusterID local | Get-RubrikSnapshot -Latest).id | Restore-RubrikVApp
      This will retreive the latest snapshot from the given vApp 'vApp01' and restore it
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the vApp snapshot to restore
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('snapshot_id')]
    [String]$id,
    # Perform a Partial vApp restore. Default operation is a Full vApp restore, unless this parameter is specified.
    [Switch]$Partial,
    # Disable NICs upon restoration. The NIC(s) will be disabled, but remain mapped to their existing network.
    [Switch]$DisableNetwork,
    # Remove network mapping upon restoration. The NIC(s) will not be connected to any existing networks.
    [Switch]$NoMapping,
    # Remove network interfaces from the restored vApp virtual machines.
    [Switch]$RemoveNetworkDevices,
    # Power on vApp after restoration.
    [Parameter(Mandatory = $true)]
    [Bool]$PowerOn,
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
    #region oneoff
    if($Partial) {}
    else {
        $recoveropts = Get-RubrikVAppRecoverOptions -id $id
        $resources.Body.vmsToRestore = $recoveropts.restorableVms
        $resources.Body.shouldPowerOnVmsAfterRecovery = $PowerOn

        if($DisableNetwork) {
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    $network.isConnected = $false
                    #$network.Properties.Remove('vappNetworkName') ?
                }
            }
        }

        if($NoMapping) {
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    $network.Properties.Remove('vappNetworkName')
                }
            }
        }

        if($RemoveNetworkDevices) {
            foreach($vm in $resources.Body.vmsToRestore) {
                $vm.networkConnections = @()
            }
        }

        if($NetworkMapping) {
            # Check RubrikVAppRecoverOptions to verify
            foreach($vm in $resources.Body.vmsToRestore) {
                foreach($network in $vm.networkConnections) {
                    $network.vappNetworkName = $NetworkMapping
                }
            }
        }

        $body = ConvertTo-Json -InputObject $resources.Body -Depth 4
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