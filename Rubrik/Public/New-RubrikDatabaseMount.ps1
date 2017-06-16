#Requires -Version 3
function New-RubrikDatabaseMount
{
  <#  
      .SYNOPSIS
      Create a new Live Mount from a protected database
      
      .DESCRIPTION
      The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected database and run it in an existing database environment.
      
      .NOTES
      Written by Mike Fal for community usage from New-RubrikMount
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the database
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # ID of Instance to use for the mount
    [Alias('InstanceId')]
    [String]$targetInstanceId,
    # Name of the mounted database
    [Alias('DatabaseName')]
    [String]$mountedDatabaseName,
    # Recovery Point desired in the form of Epoch with Milliseconds
    [Parameter(ParameterSetName='Recovery_timestamp')]
    [int64]$timestampMs,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='Recovery_DateTime')]
    [datetime]$recoveryDateTime,
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
    
    #Set epoch for recovery time calculations


    #If recoveryDateTime, convert to epoch milliseconds
    if($recoveryDateTime){  
      $epoch = ([datetime]'1/1/1970')
      $timestampMs = (New-TimeSpan -Start $epoch -End $recoveryDateTime.ToUniversalTime()).TotalMilliseconds
    } 

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
        
    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.targetInstanceId = $targetInstanceId
      $resources.Body.mountedDatabaseName = $mountedDatabaseName
      recoveryPoint = @()
    }
    $body.recoveryPoint += @{
          $resources.Body.recoveryPoint.timestampMs = $timestampMs
          }
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion


    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function