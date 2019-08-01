#Requires -Version 3
function New-RubrikSLA
{
  <#  
      .SYNOPSIS
      Creates a new Rubrik SLA Domain

      .DESCRIPTION
      The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSLA.html

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days
      while also keeping one backup per day for 30 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -AdvancedConfig -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -WeeklyFrequency 1 -WeeklyRetention 4 -DayOfWeek Friday -YearlyFrequency 1 -YearlyRetention 3 -DayOfYear LastDay -YearStartMonth February

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days
      while also keeping one backup per day for 30 days, one backup per week for 4 weeks and one backup per year for 3 years. 
      The weekly backups will be created on Fridays and the yearly backups will be created on January 31 because the year is set
      to start in February. The advanced SLA configuration can only be used with CDM version 5.0 and above.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -BackupStartHour 22 -BackupStartMinute 00 -BackupWindowDuration 8

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days. 
      Backups are allowed to run between 22:00 and 6:00AM.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -FirstFullBackupStartHour 21 -FirstFullBackupStartMinute 30 -FirstFullBackupWindowDuration 57 -FirstFullBackupDay Friday

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days. 
      The first full backup is allowed to be taken between Friday 21:30 and Monday 6:30AM.
      
      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -Archival -ArchivalLocationId 53aef5df-b628-4b61-aade-6520a2a5ba4d -LocalRetention 14 -InstantArchive

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days,
      while also keeping one backup per day for 30 days. At the same time, data is immediately copied to the specified archival location 
      and will be kept there for 14 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -Replication -ReplicationTargetId 8b4fe6f6-cc87-4354-a125-b65e23cf8c90 -RemoteRetention 5
      
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days,
      while also keeping one backup per day for 30 days. At the same time, data is replicated to the specified target cluster 
      and will be kept there for 5 days.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain Name
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('SLA')]
    [String]$Name,
    # Hourly frequency to take snapshots
    [int]$HourlyFrequency,
    # Number of days or weeks to retain the hourly snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$HourlyRetention,
    # Retention type to apply to hourly snapshots when $AdvancedConfig is used. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$HourlyRetentionType='Daily',
    # Daily frequency to take snapshots
    [int]$DailyFrequency,
    # Number of days or weeks to retain the daily snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$DailyRetention,
    # Retention type to apply to daily snapshots when $AdvancedConfig is used. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$DailyRetentionType='Daily',
    # Weekly frequency to take snapshots
    [int]$WeeklyFrequency,
    # Number of weeks to retain the weekly snapshots
    [int]$WeeklyRetention,
    # Day of week for the weekly snapshots when $AdvancedConfig is used. The default is Saturday. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [String]$DayOfWeek='Saturday',
    # Monthly frequency to take snapshots
    [int]$MonthlyFrequency,
    # Number of months, quarters or years to retain the monthly backups. For CDM versions prior to 5.0, this value must be set in years
    [int]$MonthlyRetention,
    # Day of month for the monthly snapshots when $AdvancedConfig is used. The default is the last day of the month. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','Fifteenth','LastDay')]
    [String]$DayOfMonth='LastDay',
    # Retention type to apply to monthly snapshots. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monthly','Quarterly','Yearly')]
    [String]$MonthlyRetentionType='Monthly',
    # Quarterly frequency to take snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyFrequency,
    # Number of quarters or years to retain the monthly snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyRetention,
    # Day of quarter for the quarterly snapshots when $AdvancedConfig is used. The default is the last day of the quarter. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfQuarter='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$FirstQuarterStartMonth='January',
    # Retention type to apply to quarterly snapshots. The default is Quarterly. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Quarterly','Yearly')]
    [String]$QuarterlyRetentionType='Quarterly',
    # Yearly frequency to take snapshots
    [int]$YearlyFrequency,
    # Number of years to retain the yearly snapshots
    [int]$YearlyRetention,
    # Day of year for the yearly snapshots when $AdvancedConfig is used. The default is the last day of the year. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfYear='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$YearStartMonth='January',
    # Whether to turn advanced SLA configuration on or off. Does not apply to CDM versions prior to 5.0
    [switch]$AdvancedConfig,
    [ValidateRange(0,23)]
    [int]$BackupStartHour,
    # Minute of hour from which backups are allowed to run
    [ValidateRange(0,59)]
    [int]$BackupStartMinute,
    # Number of hours during which backups are allowed to run
    [ValidateRange(1,23)]
    [int]$BackupWindowDuration,
    # Hour from which the first full backup is allowed to run. Uses the 24-hour clock
    [ValidateRange(0,23)]
    [int]$FirstFullBackupStartHour,
    # Minute of hour from which the first full backup is allowed to run
    [ValidateRange(0,59)]
    [int]$FirstFullBackupStartMinute,
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','1','2','3','4','5','6','7')]
    [String]$FirstFullBackupDay,
    # Number of hours during which the first full backup is allowed to run
    [int]$FirstFullBackupWindowDuration,
    # Whether to enable archival
    [switch]$Archival,
    # Time in days to keep backup data locally on the cluster.
    [int]$LocalRetention,
    # ID of the archival location
    [String]$ArchivalLocationId,
    # Polaris Managed ID
    [String]$PolarisID,
    # Whether to enable Instant Archive
    [switch]$InstantArchive,
    # Whether to enable replication
    [switch]$Replication,
    # ID of the replication target
    [String]$ReplicationTargetId,
    # Time in days to keep data on the replication target.
    [int]$RemoteRetention,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message 'Build the body'
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned on
    if (($uri.contains('v2')) -and $AdvancedConfig) {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $AdvancedConfig.IsPresent
        advancedUiConfig = @()
      }
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned off
    } elseif ($uri.contains('v2')) {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $AdvancedConfig.IsPresent
      }
    # Build the body for CDM versions prior to 5.0
    } else {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
      }
    }
    
    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false
    
    if ((($uri.contains('v2')) -and (-not $AdvancedConfig)) -or (-not ($uri.contains('v2')))) {
      $HourlyRetention = $HourlyRetention * 24
    }
    if (-not ($uri.contains('v2'))) {
      $MonthlyRetention = $MonthlyRetention * 12
    }

    # Populate the body with the allowed backup window settings
    if (($BackupStartHour -ge 0) -and ($BackupStartMinute -ge 0) -and $BackupWindowDuration) {
      $body.allowedBackupWindows += @{
          startTimeAttributes = @{hour=$BackupStartHour;minutes=$BackupStartMinute};
          durationInHours = $BackupWindowDuration
      }
    }

    # Populate the body with the allowed backup window settings fort the first full
    if (($FirstFullBackupStartHour -ge 0) -and ($FirstFullBackupStartMinute -ge 0) -and $FirstFullBackupDay -and $FirstFullBackupWindowDuration) {
      if ($FirstFullBackupDay -eq 'Sunday') {
        [int]$FirstFullBackupDay = 1
      } elseif ($FirstFullBackupDay -eq 'Monday') {
        [int]$FirstFullBackupDay = 2
      } elseif ($FirstFullBackupDay -eq 'Tuesday') {
        [int]$FirstFullBackupDay = 3
      } elseif ($FirstFullBackupDay -eq 'Wednesday') {
        [int]$FirstFullBackupDay = 4
      } elseif ($FirstFullBackupDay -eq 'Thursday') {
        [int]$FirstFullBackupDay = 5
      } elseif ($FirstFullBackupDay -eq 'Friday') {
        [int]$FirstFullBackupDay = 6
      } elseif ($FirstFullBackupDay -eq 'Saturday') {
        [int]$FirstFullBackupDay = 7
      }
      $body.FirstFullAllowedBackupWindows += @{
          startTimeAttributes = @{hour=$FirstFullBackupStartHour;minutes=$FirstFullBackupStartMinute;dayOfWeek=$FirstFullBackupDay};
          durationInHours = $FirstFullBackupWindowDuration
      }
    }

    # Convert LocalRetention and RemoteRetention values to seconds
    $LocalRetention = $LocalRetention * 86400
    $RemoteRetention = $RemoteRetention * 86400

    # Populate the body with archival specifications
    if ($uri.contains('v2') -and $Archival) {
      if ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
        $body.localRetentionLimit = $LocalRetention
      }
    } elseif ($Archival) {
        if ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
          $body.localRetentionLimit = $LocalRetention
        } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
          $body.localRetentionLimit = $LocalRetention
        }
    }

    # Populate the body with replication specifications
    if ($Replication -and $ReplicationTargetId -and $RemoteRetention) {
      $body.replicationSpecs += @{locationId=$ReplicationTargetId;retentionLimit=$RemoteRetention}
    }

    # Populate the body with frequencies and retentions according to the version of CDM and to whether the advanced SLA configuration is enabled in 5.x
    if ($HourlyFrequency -and $HourlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
        $body.advancedUiConfig += @{timeUnit='Hourly';retentionType=$HourlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
      } else {
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Hourly'
          $resources.Body.frequencies.frequency = $HourlyFrequency
          $resources.Body.frequencies.retention = $HourlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
        $body.advancedUiConfig += @{timeUnit='Daily';retentionType=$DailyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Daily'
          $resources.Body.frequencies.frequency = $DailyFrequency
          $resources.Body.frequencies.retention = $DailyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($WeeklyFrequency -and $WeeklyRetention) { 
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
        $body.advancedUiConfig += @{timeUnit='Weekly';retentionType='Weekly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
      } else {
        Write-Warning -Message 'Weekly SLA configurations are not supported in this version of Rubrik CDM.'
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Weekly'
          $resources.Body.frequencies.frequency = $WeeklyFrequency
          $resources.Body.frequencies.retention = $WeeklyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
        $body.advancedUiConfig += @{timeUnit='Monthly';retentionType=$MonthlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Monthly'
          $resources.Body.frequencies.frequency = $MonthlyFrequency
          $resources.Body.frequencies.retention = $MonthlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }  

    if ($QuarterlyFrequency -and $QuarterlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
        $body.advancedUiConfig += @{timeUnit='Quarterly';retentionType=$QuarterlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
      } else { 
        Write-Warning -Message 'Quarterly SLA configurations are not supported in this version of Rubrik CDM.'
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
        $body.advancedUiConfig += @{timeUnit='Yearly';retentionType='Yearly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
      } else {  
          $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Yearly'
          $resources.Body.frequencies.frequency = $YearlyFrequency
          $resources.Body.frequencies.retention = $YearlyRetention
        }
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }    
    
    $body = ConvertTo-Json $body -Depth 10
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function