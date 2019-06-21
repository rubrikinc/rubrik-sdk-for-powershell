#Requires -Version 3
function Export-RubrikVM
{
  <#  
      .SYNOPSIS
      Exports a given snapshot for a VMware VM
      
      .DESCRIPTION
      The Export-RubrikVM cmdlet is used to restore a snapshot from a protected VM, copying all data to a given datastore and running the VM in an existing vSphere environment.
      
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikVM.html

      .EXAMPLE
      Export-RubrikVM -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
      This will mount the snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to the specified host and datastore
      
      .EXAMPLE
      Get-RubrikVM 'server01' -PrimaryClusterID local | Get-RubrikSnapshot | Sort-Object -Property Date -Descending | Select -First 1 | Export-RubrikVM -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
      This will retreive the latest snapshot from the given VM 'server01' and export to the specified host and datastore.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the snapshot to export
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Rubrik id of the vSphere datastore to store exported VM. (Use "Invoke-RubrikRESTCall -Endpoint 'vmware/datastore' -Method 'GET' -api 'internal'" to retrieve a list of available VMware datastores)
    [Parameter(Mandatory = $true)]
    [String]$DatastoreId,
    # ID of host for the export to use (Use "Invoke-RubrikRESTCall -Endpoint 'vmware/host' -Method 'GET' -api '1'" to retrieve a list of available VMware hosts.)
    [Parameter(Mandatory = $true)]
    [String]$HostID,
    # Name of the exported VM 
    [String]$VMName,
    # Whether the network should be disabled upon restoration. This should be set true to avoid ip conflict if source VM still exists. 
    [Bool]$DisableNetwork,
    # Whether to remove network interfaces from the restored virtual machine. Default is false.
    [Bool]$RemoveNetworkDevices,
    # Whether to assign MAC addresses from source virtual machine to exported virtual machine. Default is false.
    [Bool]$KeepMACAddresses,
    # Whether the newly restored virtual machine is unregistered from vCenter. Default is false.
    [Bool]$UnregisterVM,
    # Whether the VM should be powered on after restoration. Default is true.
    [Bool]$PowerOn,
    # Whether to recover vSphere tags
    [Alias('shouldRecoverTags')]
    [Bool]$RecoverTags,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function