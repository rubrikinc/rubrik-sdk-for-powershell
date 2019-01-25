#requires -Version 3
function Set-RubrikAvailabilityGroup
{
  <#  
      .SYNOPSIS
      Sets the protection values of an Availability Group

      .DESCRIPTION
      The Set-RubrikAvailabilityGroup cmdlet is used to set the protetion values of an Availability Group in Rubrik.

      .NOTES
      Written by Chris Lumnah for community usage
      Twitter: @lumnah
      GitHub: clumnah

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD
      This will set the SLA Domain to GOLD for this Availability Group

      .EXAMPLE
      Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD -LogBackupFrequencyInSeconds 3600 -LogRetentionHours 168
      This will set the SLA Domain to GOLD for this Availability Group with a log backup frequency of hourly and a retention of 15 days

  #>

  [CmdletBinding()]
  Param(
    #Availability Group ID
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    #How often we should backup the transaction log  
    [int]$LogBackupFrequencyInSeconds =-1,
    
    #How long should we keep the backup for
    [int]$LogRetentionHours =-1,    

    #Boolean declaration for copy only backups on the database.
    [switch]$CopyOnly,   

    #SLA Domain Name
    [string]$SLA,

    #SLA Domain ID
    [Alias("configuredSlaDomainId")]
    [string]$SLAID,
    
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

    Begin 
    {

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

  Process 
  {
    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    
    $body = @{
        $resources.Body.logRetentionHours = $logRetentionHours
        $resources.Body.logBackupFrequencyInSeconds = $logBackupFrequencyInSeconds
        $resources.Body.configuredSlaDomainId = $SLAID
        $resources.Body.copyOnly = $CopyOnly.ToBool()
      }
    #If the following params are -1, remove from body (invalid values)
    $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours')
    foreach($p in $intparams)
    {
        if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
    }     
    $body = ConvertTo-Json $body
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
#    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)  
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
