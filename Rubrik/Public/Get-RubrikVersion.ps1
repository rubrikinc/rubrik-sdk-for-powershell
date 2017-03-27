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
    [String]$Server = $global:RubrikConnection.server,
    # API version
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
    $uri = $uri -replace '{id}', 'me'

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

    $result = (ConvertFrom-Json -InputObject $r.Content)
    $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    return $result


  } # End of process
} # End of function