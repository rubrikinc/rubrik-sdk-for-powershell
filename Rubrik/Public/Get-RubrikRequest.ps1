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
    [Alias('requestId')]
    [String]$ID,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection

    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('VMwareVMRequestGet')
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $ID
    
    # Set the method
    $method = $resources.$api.Method
        
    try
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
      if ($r.StatusCode -ne $resources.$api.SuccessCode) 
      {
        Write-Warning -Message 'Did not receive successful status code from Rubrik'
        throw $_
      }
      $response = ConvertFrom-Json -InputObject $r.Content
      return $response
    }
    catch
    {
      throw $_
    }
		
  } # End of process
} # End of function