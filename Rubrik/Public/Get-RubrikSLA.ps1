#Requires -Version 3
function Get-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on SLA Domain(s)
            
      .DESCRIPTION
      The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
      Information on each domain will be reported to the console.
            
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
    # Name of the SLA Domain (alias: 'name')
    # Default: Will retrieve information on all known SLA Domains
    # Pipeline: Accepted by property name
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$SLA,
    # SLA Domain id
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
    $resources = Get-RubrikAPIData -endpoint ('SLADomainGet')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($id) 
    {
      $uri += "/$id"
    }
    
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
      $result = Test-ReturnFilter -object $SLA -location $resources.$api.Filter['$SLA'] -result $result
    }
    
    return $result   
		
  } # End of process
} # End of function