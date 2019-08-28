#requires -Version 3
function New-RubrikLogShipping
{
  <#  
  .SYNOPSIS
  Create a log shipping configuration within Rubrik

  .DESCRIPTION
  Create a log shipping configuration within Rubrik

  .NOTES
  Written by Chris Lumnah
  Twitter: lumnah
  GitHub: clumnah
  
  .LINK
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/

  .EXAMPLE
  $RubrikDatabase = Get-RubrikDatabase -Name 'AthenaAM1-SQL16-1-2016' -Hostname am1-sql16-1
  $RubrikSQLInstance = Get-RubrikSQLInstance -Hostname am1-chrilumn-w1 -instance MSSQLSERVER
  New-RubrikLogShipping -id $RubrikDatabase.id -state 'STANDBY' -targetDatabaseName 'AthenaAM1-SQL16-1-2016' -targetDataFilePath 'c:\sqldata' -targetLogFilePath 'c:\sqldata' -targetInstanceId $RubrikSQLInstance.id -Verbose
  #>

  [CmdletBinding()]
  Param(
    # Rubrik identifier of database to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,

    [ValidateSet("RESTORING", "STANDBY")]
    [String]$state,

    [Alias('shouldDisconnectStandbyUsers')]
    [switch]$DisconnectStandbyUsers,

    [Parameter(Mandatory = $true)]
    [String]$targetDatabaseName, 

    [Parameter(Mandatory = $false)]
    [String]$targetDataFilePath, 

    [Parameter(Mandatory = $false)]
    [String]$targetLogFilePath,    
    
    [Parameter(Mandatory = $true)]
    [String]$targetInstanceId,  

    #Advanced Mode - Array of hash tables for file reloaction.
    [PSCustomObject[]] $TargetFilePaths,  

    # Number of parallel streams to copy data
    [int]$MaxDataStreams,

    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,

    # API version
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
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"

  }

  Process {
    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.targetInstanceId = $TargetInstanceId
      $resources.Body.targetDatabaseName = $TargetDatabaseName
      $resources.Body.state = $state
    }

    if($DisconnectStandbyUsers){
      $body.Add($resources.Body.shouldDisconnectStandbyUsers,$DisconnectStandbyUsers)
    }

    if($MaxDataStreams){
      $body.Add($resources.Body.maxDataStreams,$MaxDataStreams)
    }

    if([string]::IsNullOrWhiteSpace($TargetFilePaths) -eq $false)
    {
      if($TargetDataFilePath -or $TargetLogFilePath) {Write-Warning 'Use of -TargetFilePaths overrides -TargetDataFilePath and -TargetLogFilePath.'}
      $body.Add('targetFilePaths',$TargetFilePaths)
    } 
    else 
    {
      if($TargetDataFilePath){ $body.Add('targetDataFilePath',$TargetDataFilePath) }
      if($TargetLogFilePath){ $body.Add('targetLogFilePath',$TargetLogFilePath) }
    }
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function