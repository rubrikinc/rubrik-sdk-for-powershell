#Requires -Version 3
function Get-RubrikDatabaseFiles
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves all the data files for a SQL Server Database snapshot
            
      .DESCRIPTION
      The Get-RubrikDatabaseFiles cmdlet will return all the available databasem files for a database 
      snapshot. This is based on the recovery time for the database, as file locations could change
      between snapshots and log backups. If no date time is provided, the database's latest recovery
      point will be used

      ***WARNING***
      This is based on an internal endpoint and is subject to change by the REST API team.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDatabaseFiles.html
            
      .EXAMPLE
      Get-RubrikDatabaseFiles -id '11111111-2222-3333-4444-555555555555'
      This will return files for database id  "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -RecoveryDateTime (Get-Date).AddDays(-1)
      This will return details on mount id "11111111-2222-3333-4444-555555555555" from a recovery point one day ago, assuming that recovery point exists.

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -time '2017-08-08T01:15:00Z'
      This will return details on mount id "11111111-2222-3333-4444-555555555555" from UTC '2017-08-08 01:15:00', assuming that recovery point exists.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Recovery Point desired in the form of DateTime value
    [datetime]$RecoveryDateTime,
    # Recovery Point desired in the form of a UTC string (yyyy-MM-ddTHH:mm:ss)
    [string]$time,
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
    if($RecoveryDateTime){$time = $RecoveryDateTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')}

    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    # Recovery Point desired in the form of Epoch with Milliseconds


    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
