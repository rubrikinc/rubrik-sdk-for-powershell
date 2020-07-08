#Requires -Version 3
function Restore-RubrikDatabase
{
  <#
      .SYNOPSIS
      Connects to Rubrik and restores a MSSQL database

      .DESCRIPTION
      The Restore-RubrikDatabase command will request a database restore from a Rubrik Cluster to a MSSQL instance. This
      is an inplace restore, meaning it will overwrite the existing asset.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .EXAMPLE
      Restore-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -FinishRecovery -maxDataStreams 4 -timestampMs 1492661627000
      
      Restore database to declared epoch ms timestamp.

      .EXAMPLE
      Restore-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -maxDataStreams 1 -FinishRecovery

      Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database.

      .EXAMPLE
      Get-RubrikDatabase -Name db01 | Restore-RubrikDatabase -FinishRecovery -maxDataStreams 6 -timestampMs 3492661627000
      
      Restore using the pipeline to get the database ID.
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/restore-rubrikdatabase
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik identifier of database to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # Number of parallel streams to copy data
    [int]$MaxDataStreams,
    # Recovery Point desired in the form of Epoch with Milliseconds
    [Parameter(ParameterSetName='Recovery_timestamp')]
    [int64]$TimestampMs,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='Recovery_DateTime')]
    [datetime]$RecoveryDateTime,
    # Recovery Point desired in the form of an LSN (Log Sequence Number)
    [Parameter(ParameterSetName='Recovery_LSN')]
    [string]$RecoveryLSN,
    # If FinishRecover is true, fully recover the database
    [Switch]$FinishRecovery,
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

    #If recoveryDateTime, convert to epoch milliseconds
    if($recoveryDateTime){  
      $TimestampMs = ConvertTo-EpochMS -DateTimeValue $RecoveryDateTime
    } 
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.finishRecovery = $FinishRecovery.IsPresent
    }

    if($MaxDataStreams){
      $body.Add($resources.Body.maxDataStreams,$MaxDataStreams)
    }

    if($RecoveryLSN){
      $body.recoveryPoint = @{lsnPoint=@{lsn=$RecoveryLSN}}
    } else {
      $body.recoveryPoint = @{timestampMs = $TimestampMs}
    }

    $body = ConvertTo-Json $body -depth 10
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function