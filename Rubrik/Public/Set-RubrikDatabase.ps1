#requires -Version 3
function Set-RubrikDatabase
{
  <#  
      .SYNOPSIS
      Sets Rubrik database properties

      .DESCRIPTION
      The Set-RubrikDatabase cmdlet is used to update certain settings for a Rubrik database.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
.

      .EXAMPLE

      .EXAMPLE
  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's database id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    #Number of seconds between log backups if db is in FULL or BULK_LOGGED
    [int]$LogBackupFrequencyInSeconds,
    #Number of hours backups will be retained in Rubrik
    [int]$LogRetentionHours,
    #Boolean declaration for copy only backups on the database.
    [bool]$CopyOnly,
    #Number of max data streams Rubrik will use to back up the database
    [int]$MaxDataStreams,
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
  
  }

  Process {

    #region One-off
    if($SLA){
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
