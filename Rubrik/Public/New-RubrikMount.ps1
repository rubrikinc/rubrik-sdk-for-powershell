#Requires -Version 3
function New-RubrikMount
{
  <#  
      .SYNOPSIS
      Create a new Live Mount from a protected VM
      
      .DESCRIPTION
      The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
      
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikMount -id '11111111-2222-3333-4444-555555555555'
      This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555"
      The original virtual machine's name will be used along with a date and index number suffix
      The virtual machine will be powered on upon completion of the mount operation
      
      .EXAMPLE
      New-RubrikMount -id '11111111-2222-3333-4444-555555555555' -MountName 'Mount1' -PowerState:$false
      This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555" and name the mounted virtual machine "Mount1"
      The virtual machine will NOT be powered on upon completion of the mount operation

      .EXAMPLE
      Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/01/2017 01:00' | New-RubrikMount -MountName 'Mount1' -DisableNetwork
      This will create a new mount based on the closet snapshot found on March 1st, 2017 @ 01:00 AM and name the mounted virtual machine "Mount1"
      The virtual machine will be powered on upon completion of the mount operation

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the snapshot
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # ID of host for the mount to use 
    [String]$HostID,
    # Name of the mounted VM 
    [Alias('vmName')]
    [String]$MountName,
    # Name of the data store to use/create on the host 
    [String]$DatastoreName,
    # Whether the network should be disabled on mount.This should be set true to avoid ip conflict in case of static IPs. 
    [Switch]$DisableNetwork,
    # Whether the network devices should be removed on mount.
    [Switch]$RemoveNetworkDevices,
    # Whether the VM should be powered on after mount.
    [Alias('powerOn')]
    [Switch]$PowerState,
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
    $resources = (Get-RubrikAPIData -endpoint $function).$api
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