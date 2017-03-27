#Requires -Version 3
function Get-RubrikMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a VM
            
      .DESCRIPTION
      The Get-RubrikMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
      Due to the nature of names not being unique
      Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
      It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikMount.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikMount
      This will return details on all mounted virtual machines.

      .EXAMPLE
      Get-RubrikVM -VM 'Server1' | Get-RubrikMount
      Will return all mounts found mathcing the virtual machine name of 'Server1'.

      .EXAMPLE
      Get-RubrikMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".
                  
      .EXAMPLE
      Get-RubrikMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
      This will return details for any mounts found using the virtual machine id of 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' as a base reference.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's mount id value
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$id,
    # The Rubrik ID value of the mount
    [String]$VMID,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMSnapshotMountGet')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($id) 
    {
      $uri += "/$id"
    }
    
    Write-Verbose -Message 'Build the query parameters'
    $query = @()
    $query += Test-QueryObject -object $VMID -location $resources.$api.Query.VMID -query $query
    $uri = New-QueryString -query $query -uri $uri -nolimit $true    

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method
        
    try 
    {
      Write-Verbose -Message "Submitting a request to $uri"
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
      
      Write-Verbose -Message 'Convert JSON content to PSObject (Max 64MB)'
      $result = ExpandPayload -response $r
    }          
    catch 
    {
      throw $_
    }
      
    if (!$id)
    {
      Write-Verbose -Message 'Formatting return value'
      $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    }           

    return $result

  } # End of process
} # End of function
