#Requires -Version 3
function Get-RubrikVersion
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current version
            
      .DESCRIPTION
      The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikVersion
      This will return the running version on the Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(Position = 0)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('ClusterVersionGet')
  
  }

  Process {
    
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($api -ne 'v0') 
    {
      $uri = $uri -replace '{id}', 'me'
    }

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    try 
    {
      Write-Verbose -Message 'Query Rubrik for SLA Domain Information'  
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
      $result = (ConvertFrom-Json -InputObject $r.Content)
      return $result
    }
    catch 
    {
      throw $_
    }


  } # End of process
} # End of function