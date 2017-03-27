#Requires -Version 3
function Get-RubrikRequest 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on an async request
            
      .DESCRIPTION
      The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
      This is helpful for tracking the state (success, failure, running, etc.) of a request.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikRequest -ID MOUNT_SNAPSHOT_123456789:::0
      Will return details about the request named "MOUNT_SNAPSHOT_123456789:::0"
  #>

  [CmdletBinding()]
  Param(
    # SLA Domain Name
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)]
    [ValidateNotNullorEmpty()]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('VMwareVMRequestGet')
  
  }

  Process {
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    $uri = $uri -replace '{id}', $id
    
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

    $response = ConvertFrom-Json -InputObject $r.Content
    return $response
		
  } # End of process
} # End of function