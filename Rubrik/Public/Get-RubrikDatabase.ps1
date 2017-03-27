#requires -Version 3
function Get-RubrikDatabase
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more databases known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikDatabase cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of databases.
      To narrow down the results, use the host and instance parameters to limit your search to a smaller group of objects.
      Alternatively, supply the Rubrik database ID to return only one specific database.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikDatabase -Database 'DB1' -SLA Gold
      This will return details on all databases named DB1 protected by the Gold SLA Domain on any known host or instance.

      .EXAMPLE
      Get-RubrikDatabase -Host 'Host1' -Instance 'MSSQLSERVER' -Database 'DB1'
      This will return details on a database named "DB1" living on an instance named "MSSQLSERVER" on the host named "Host1".

      .EXAMPLE
      Get-RubrikDatabase -Relic
      This will return all removed databases that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase -id 'MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      This will return details on a single database matching the Rubrik ID of "MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      Note that the database ID is globally unique and is often handy to know if tracking a specific database for longer workflows,
      whereas some values are not unique (such as nearly all hosts having one or more databases named "model") and more difficult to track by name.
  #>

  [CmdletBinding()]
  Param(
    # Name of the database (alias: 'name')
    # Default: Will retrieve information on all known databases
    # Pipeline: Accepted by property name
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('Name')]
    [String]$Database,
    # Filter results to include only relic (removed) databases
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the database instance
    [String]$Instance,    
    # Name of the database host
    [String]$Host,
    # Rubrik's database id value
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
    $resources = Get-RubrikAPIData -endpoint ('MSSQLDBGet')
  
  }
  
  Process {

    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    if ($id) 
    {
      $uri += "/$id"
    }

    Write-Verbose -Message 'Build the query parameters'
    $query = @()
    $query += Test-QueryObject -object ([boolean]::Parse($Relic)) -location $resources.$api.Query.Relic -query $query
    $query += Test-QueryObject -object (Test-RubrikSLA -SLA $SLA) -location $resources.$api.Query.SLA -query $query    
    $uri = New-QueryString -query $query -uri $uri -nolimit $true

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
      $result = Test-ReturnFilter -object $Database -location $resources.$api.Filter['$Database'] -result $result
      $result = Test-ReturnFilter -object $SLA -location $resources.$api.Filter['$SLA'] -result $result
      $result = Test-ReturnFilter -object $Instance -location $resources.$api.Filter['$Instance'] -result $result
      $result = Test-ReturnFilter -object $Host -location $resources.$api.Filter['$Host'] -result $result
    }
    
    if (!$id) 
    {      
      Write-Verbose -Message 'Formatting return value'
      $result = Test-ReturnFormat -api $api -result $result -location $resources.$api.Result
    }
    
    return $result

  } # End of process
} # End of function
