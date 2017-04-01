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
    # Name of the database
    [Alias('Database')]
    [String]$Name,
    # Filter results to include only relic (removed) databases
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the database instance
    [String]$Instance,    
    # Name of the database host
    [String]$Hostname,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    
    # Rubrik's database id value
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
