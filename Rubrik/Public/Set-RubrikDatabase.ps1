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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikDatabase

      .EXAMPLE
      Set-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -LogBackupFrequencyInSeconds 900

      Set the target database's log backup interval to 15 minutes (900 seconds)

      .EXAMPLE
      Get-RubrikDatabase -HostName Foo -Instance MSSQLSERVER | Set-RubrikDatabase -SLA 'Silver' -CopyOnly 

      Set all databases on host FOO to use SLA Silver and be copy only.

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -PreScriptPath "c:\temp\test.bat" -PreScriptErrorAction "continue" -PreTimeoutMs 300 
      
      Set a script to run before a Rubrik Backup runs against the database

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -PostScriptPath "c:\temp\test.bat" -PostScriptErrorAction "continue" -PostTimeoutMs 300 
      
      Set a script to run after a Rubrik Backup runs against the database

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -DisablePreBackupScript 
      
      Remove a script from running before a Rubrik Backup

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -DisablePostBackupScript 
      
      Remove a script from running after a Rubrik Backup
  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's database id value
    [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    #Number of seconds between log backups if db is in FULL or BULK_LOGGED
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogBackupFrequencyInSeconds = -1,
    #Number of hours backups will be retained in Rubrik
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogRetentionHours = -1,
    #Boolean declaration for copy only backups on the database.
    [Switch]$CopyOnly,
    #Pre-backup script parameters
    [Parameter(ParameterSetName = 'preBackupScript')]
    [string]$PreScriptPath,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [ValidateSet('abort','continue')]
    [string]$PreScriptErrorAction,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [int]$PreTimeoutMs,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [switch]$DisablePreBackupScript,
    #Post-backup script parameters
    [Parameter(ParameterSetName = 'postBackupScript')]
    [string]$PostScriptPath,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [ValidateSet('abort','continue')]
    [string]$PostScriptErrorAction,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [int]$PostTimeoutMs,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [switch]$DisablePostBackupScript,
    #Number of max data streams Rubrik will use to back up the database
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
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    #region One-off
    if($SLA){
      $SLAID = Test-RubrikSLA $SLA
    }
    
    #If the following params are -1, remove from body (invalid values)
    $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours','MaxDataStreams')
    foreach($p in $intparams){
      if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
    }

    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    

    #Pre Backup script
    #region Enable Pre Backup Script
    if($PreScriptPath)
    {
      $bodytemp = ConvertFrom-Json $body
      $pre = New-Object psobject -Property @{'scriptPath'=$PreScriptPath;'timeoutMs'=$PreTimeoutMs;'scriptErrorAction'=$PreScriptErrorAction}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'preBackupScript' -Value $pre
      $body = ConvertTo-Json $bodytemp
    }
    #endregion
    #region Disable Pre Backup Script
    if($DisablePreBackupScript -eq $true -and ([string]::IsNullOrEmpty($PreScriptPath)))
    {
      $bodytemp = ConvertFrom-Json $body
      $pre = New-Object psobject -Property @{'scriptPath'=$null;'timeoutMs'=$Null;'scriptErrorAction'=$Null}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'preBackupScript' -Value $pre
      $body = ConvertTo-Json $bodytemp
    } 
    elseif(($DisablePreBackupScript) -and -not ([string]::IsNullOrEmpty($PreScriptPath)))
    {
      $msg = "Can not declare -PreScriptPath and -DisablePreBackupScript in the same request."
      Write-Warning $msg
      return $msg
    }
    #endregion

    #Post Backup script
    #region Enable Post Backup Script
    if($PostScriptPath)
    {
      $bodytemp = ConvertFrom-Json $body
      $Post = New-Object psobject -Property @{'scriptPath'=$PostScriptPath;'timeoutMs'=$PostTimeoutMs;'scriptErrorAction'=$PostScriptErrorAction}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'postBackupScript' -Value $Post
      $body = ConvertTo-Json $bodytemp
    }
    #endregion
    #region Disable Post Backup Script
    
    if($DisablePostBackupScript -eq $true -and ([string]::IsNullOrEmpty($PostScriptPath)))
    {
      $bodytemp = ConvertFrom-Json $body
      $Post = New-Object psobject -Property @{'scriptPath'=$null;'timeoutMs'=$Null;'scriptErrorAction'=$Null}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'postBackupScript' -Value $Post
      $body = ConvertTo-Json $bodytemp
    } 
    elseif(($DisablePostBackupScript) -and -not ([string]::IsNullOrEmpty($PostScriptPath)))
    {
      $msg = "Can not declare -PostScriptPath and -DisablePostBackupScript in the same request."
      Write-Warning $msg
      return $msg
    }
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
