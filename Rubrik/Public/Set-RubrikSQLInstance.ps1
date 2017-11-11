#requires -Version 3
function Set-RubrikSQLInstance
{
  <#  
      .SYNOPSIS
      Sets SQL Instance properties

      .DESCRIPTION
      The Set-RubrikSQLInstance cmdlet is used to update certain settings for a Rubrik SQL instance.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      {required: show one or more examples using the function}
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's database id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    #Number of seconds between log backups if db s are in FULL or BULK_LOGGED
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogBackupFrequencyInSeconds = -1,
    #Number of hours backups will be retained in Rubrik
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogRetentionHours = -1,
    #Boolean declaration for copy only backups on the instance.
    [Switch]$CopyOnly,
    #Number of max data streams Rubrik will use to back up the instance
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$MaxDataStreams = -1,
    #SLA Domain ID for the database
    [Alias('ConfiguredSlaDomainId')]
    [string]$SLAID,
    # The SLA Domain name in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
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

    #region One-off
    if($SLA){
        $SLAID = (Get-RubrikSLA -Name $SLA).id
      }
      
      #If the following params are -1, remove from body (invalid values)
      $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours','MaxDataStreams')
      foreach($p in $intparams){
        if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
      }
  
      #endregion
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
