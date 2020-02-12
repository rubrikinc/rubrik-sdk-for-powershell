#Requires -Version 3
function Get-RubrikHyperVMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a HyperV VM
            
      .DESCRIPTION
      The Get-RubrikHyperVMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
      Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
      It is suggested that you first use Get-RubrikHyperVVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikHyperVMount.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikHyperVMount
            
      .EXAMPLE
      Get-RubrikHyperVMount
      This will return details on all mounted virtual machines.

      .EXAMPLE
      Get-RubrikHyperVMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikHyperVMount -VMID (Get-RubrikHyperVVM -VM 'Server1').id
      This will return details for any mounts found using the id value from a virtual machine named "Server1" as a base reference.
                  
      .EXAMPLE
      Get-RubrikHyperVMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
      This will return details for any mounts found using the virtual machine id of 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' as a base reference.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Filters live mounts by VM ID
    [Alias('vm_id')]
    [String]$VMID,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function