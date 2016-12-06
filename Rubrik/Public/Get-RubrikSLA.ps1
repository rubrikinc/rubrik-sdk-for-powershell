#Requires -Version 3
function Get-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on SLA Domain(s)
            
      .DESCRIPTION
      The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information on each
      domain will be reported to the console.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikSLA
      Will return all known SLA Domains
            
      .EXAMPLE
      Get-RubrikSLA -SLA 'Gold'
      Will return details on the SLA Domain named Gold
  #>

  [CmdletBinding()]
  Param(
    # SLA Domain Name
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$SLA,
    # Rubrik server IP or FQDN
    [Parameter(Position = 2)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 3)]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
    
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('SLADomainGet')
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    
    # Set the method
    $method = $resources.$api.Method
        
    try 
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $header -Method $method
      $response = ConvertFrom-Json -InputObject $r.Content
      
      # Strip out the overhead for the newer APIs
      if ($api -ne 'v0')
      {
        $response = $response.data
      }
      
      # Optionally filter out the results for a specific SLA Domain
      if ($SLA)
      {
        Write-Verbose -Message "Filtering results for $SLA"
        [array]$response = $response | Where-Object -FilterScript {
          $_.name -eq $SLA
        }
      }
      
      return $response
    }
    catch
    {
      throw $_
    }   
		
  } # End of process
} # End of function