#Requires -Version 3
function Get-RubrikMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a VM
            
      .DESCRIPTION
      The Get-RubrikMount cmdlet will accept a VM name and return details on any mount operations that are active within Rubrik
            
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
      Get-RubrikMount -VM Server1
      Will return all Live Mounts found for Server1
            
      .EXAMPLE
      Get-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
      Will return all Live Mounts found for the Rubrik ID 1234567890
  #>

  [CmdletBinding()]
  Param(
    # Virtual Machine to inspect for mounts
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$VM,
    # The Rubrik ID value of the mount
    [Parameter(Position = 1,ValueFromPipelineByPropertyName = $true)]
    [Alias('id')]
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

  Process {

    TestRubrikConnection
    
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('VMwareVMMountGet')
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    
    # Set the method
    $method = $resources.$api.Method
        
    try 
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $header -Method $method
      $mounts = ConvertFrom-Json -InputObject $r.Content
      
      # Strip out the overhead for the newer API
      if ($api -ne 'v0') 
      {
        $mounts = $mounts.data
      }

      # Filter out specific VMs if the user supplied a value
      if ($VM)
      {
        Write-Verbose -Message "Filtering results for $VM"
        [array]$mounts = $mounts | Where-Object -FilterScript {
          $_.sourcevirtualMachineName -eq $VM
        }
      }
      
      # Filter out specific Mount IDs if the user supplied a value
      if ($MountID) 
      {
        Write-Verbose -Message "Filtering results for $MountID"
        [array]$mounts = $mounts | Where-Object -FilterScript {
          $_.id -eq $MountID
        }
      }

      return $mounts
      
    }
    catch 
    {
      throw $_
    }

  } # End of process
} # End of function