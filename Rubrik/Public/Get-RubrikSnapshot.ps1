#Requires -Version 3
function Get-RubrikSnapshot
{
  <#  
      .SYNOPSIS
      Retrieves all of the snapshots (backups) for a given virtual machine
      
      .DESCRIPTION
      The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for a protected virtual machine
      
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
      
      .EXAMPLE
      Get-RubrikSnapshot -VM 'Server1'
      This will return an array of details for each snapshot (backup) for Server1
  #>

  [CmdletBinding()]
  Param(
    # Name of the virtual machine    
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # Rubrik server IP or FQDN
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
    
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('VMwareVMSnapshotGet')

    Write-Verbose -Message 'Query Rubrik for the list of protected VM details'
    $vmids = (Get-RubrikVM -VM $VM).id
    
    # Possible to have multiple results for a VM name.
    foreach ($vmid in $vmids)
    {
      Write-Verbose -Message 'Building the URI'
      $uri = 'https://'+$Server+$resources.$api.URI
      # Replace the placeholder of {id} with the actual VM ID
      $uri = $uri -replace '{id}', $vmid
        
      # Set the method
      $method = $resources.$api.Method

      Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
      try 
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
        $result = (ConvertFrom-Json -InputObject $r.Content)
        if (!$result) 
        {
          throw 'No snapshots found for VM.'
        }
        elseif ($api -ne 'v0')
        {
          return $result.data
        }
        else 
        {
          return $result
        }
      }
      catch 
      {
        throw $_
      }
    }

  } # End of process
} # End of function