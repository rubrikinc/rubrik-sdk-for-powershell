#requires -Version 3
function Get-RubrikDatabaseRecoverableRange
{
  <#  
      .SYNOPSIS
      Retrieves recoverable ranges for SQL Server databases.

      .DESCRIPTION
      The Get-RubrikDatabaseRecoverableRange cmdlet retrieves recoverable ranges for
      SQL Server databases protected by Rubrik. 

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange

      Retrieve all recoverable ranges for the BAR database on the FOO host.

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -BeforeTime '2018-03-31T00:00:00.000Z'

      Retrieve all recoverable ranges for the BAR database on the FOO host after '2018-03-31T00:00:00.000Z'.

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -EndTime '2018-04-01'

      Retrieve all recoverable ranges for the BAR database on the FOO host before '2018-04-01' after it's converted to UTC.

  #>

  [CmdletBinding()]
  Param(
    # Rubrik's database id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    #Range Start as datetime
    [datetime]$StartDateTime,
    #Range End as datetime
    [datetime]$EndDateTime,
    # After time/Start time of range in ISO8601 format (2016-01-01T01:23:45.678Z)
    [Alias('after_time')]
    [String]$AfterTime,
    # Before time/end time of range in ISO8601 format (2016-01-01T01:23:45.678Z)
    [Alias('before_time')]
    [String]$BeforeTime,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {
    #region oneoff
    if($StartDateTime){$AfterTime = $StartDateTime.ToUniversalTime().ToString('O')}
    if($EndDateTime){$BeforeTime = $EndDateTime.ToUniversalTime().ToString('O')}

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
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

    #region oneoff
    
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function