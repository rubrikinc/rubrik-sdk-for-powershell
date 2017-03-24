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
      Will return all Live Mounts known to Rubrik

      .EXAMPLE
      Get-RubrikVM -VM 'Server1' | Get-RubrikMount
      Will return all Live Mounts found for Server1
            
      .EXAMPLE
      Get-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
      Will return details on a live mount matching the id of "11111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding()]
  Param(
    # Virtual Machine ID to inspect for mounts
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
    [ValidateNotNullorEmpty()]
    [String]$VMID,
    # The Rubrik ID value of the mount
    [Parameter(Position = 1,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [String]$MountID,
    # Rubrik server IP or FQDN
    [Parameter(Position = 2)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMMountGet')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($MountID) 
    {
      $uri += "/$MountID"
    }
    
    Write-Verbose -Message 'Build the query parameters'
    $params = @()
    $params += Test-QueryObject -object $VMID -location $resources.$api.Params.VMID -params $params
    $uri = New-QueryString -params $params -uri $uri -nolimit $true    

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
      
    if (!$MountID)
    {
      Write-Verbose -Message 'Formatting return value'
      $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result

    }           

    return $result

  } # End of process
} # End of function
