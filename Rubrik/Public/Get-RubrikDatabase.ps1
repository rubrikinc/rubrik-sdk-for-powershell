#requires -Version 3
function Get-RubrikDatabase
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more databases known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikDatabase cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of databases

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      !!!!!!!!!!!!!!!!!!!!!!!!!!Get-RubrikVM -VM 'Server1'
      This will return the ID of the virtual machine named Server1
  #>

  [CmdletBinding()]
  Param(
    # Name of the database
    # If no value is specified, will retrieve information on all databases
    [Parameter(Position = 0,ValueFromPipeline = $true)]
    [Alias('Name')]
    [String]$Database,
    # Filter results based on active, relic (removed), or all databases
    [Parameter(Position = 1)]
    [Alias('archiveStatusFilterOpt','archive_status')]
    [ValidateSet('ACTIVE', 'RELIC')]
    [String]$Filter,
    # SLA Domain policy
    [Parameter(Position = 2,ValueFromPipeline = $true)]
    [Alias('sla_domain_id')]    
    [String]$SLA,        
    # Rubrik server IP or FQDN
    [Parameter(Position = 3)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 4)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('MSSQLDBGet')
  
  }
  
  Process {

    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI

    Write-Verbose -Message 'Build the query parameters'
    $params = @()
    $params += Test-QueryObject -object $Filter -location $resources.$api.Params.Filter -params $params
    $params += Test-QueryObject -object $Database -location $resources.$api.Params.Search -params $params
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
      
    Write-Verbose -Message 'Formatting return value'
    $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    $result = Test-ReturnFilter -object $Database -location $resources.$api.Filter['$Database'] -result $result
    $result = Test-ReturnFilter -object $SLA -location $resources.$api.Filter['$SLA'] -result $result
    
    return $result

  } # End of process
} # End of function
