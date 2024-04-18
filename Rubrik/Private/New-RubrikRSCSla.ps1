function New-RubrikRSCSla {
    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
      # SLA Domain Name, either the -Name parameter or its parameter alias -SLA can be used to specify the name of the SLA
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
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [alias('showAdvancedUi')]
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
      # Whether to enable archival, does not take any input and should be used in combination with -ArchivalLocationId
      [switch]$Archival,
      # Time in days to keep backup data locally on the cluster.
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [alias('localRetentionLimit')]
      [int]$LocalRetention,
      # ID of the archival location
      [ValidateNotNullOrEmpty()]
      [String]$ArchivalLocationId,
      # Polaris Managed ID
      [ValidateNotNullOrEmpty()]
      [String]$PolarisID,
      # Whether to enable Instant Archive
      [switch]$InstantArchive,
      # Whether a retention lock is active on this SLA, Does not apply to CDM versions prior to 5.2
      [alias('isRetentionLocked')]
      [switch]$RetentionLock,
      # Whether to enable replication
      [switch]$Replication,
      # ID of the replication target
      [ValidateNotNullOrEmpty()]
      [String]$ReplicationTargetId,
      # Time in days to keep data on the replication target.
      [int]$RemoteRetention,
      # Retrieves frequencies from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [object[]] $Frequencies,
      # Retrieves the advanced UI configuration parameters from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [alias('advancedUiConfig')]
      [object[]] $AdvancedFreq,
      # Retrieves the allowed backup windows from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [alias('allowedBackupWindows')]
      [object[]] $BackupWindows,
      # Retrieves the allowed backup windows for the first full backup from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [alias('firstFullAllowedBackupWindows')]
      [object[]] $FirstFullBackupWindows,
      # Retrieves the archical specifications from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [object[]] $ArchivalSpecs,
      # Retrieves the replication specifications from Get-RubrikSLA via the pipeline
      [Parameter(
        ValueFromPipelineByPropertyName = $true)]
      [object[]] $ReplicationSpecs,
      # Rubrik server IP or FQDN
      [String]$Server = $global:RubrikConnection.server,
      # API version
      [String]$api = $global:RubrikConnection.api
    )

    $RscParams = @{}

    if ($Name) {
        $RscParams.Add("Name",$Name)
    }

    if ($HourlyFrequency) {
        if ($HourlyRetentionType -eq "Weekly") {
            $RetentionUnit = "WEEKS"
        } else {
            $RetentionUnit = "DAYS"
        }
        $hourlySchedule = New-RscSlaSnapshotSchedule -Type Hourly -Frequency $HourlyFrequency -Retention $HourlyRetention -RetentionUnit $RetentionUnit
        $RscParams.Add("HourlySchedule", $hourlySchedule)
    }
    if ($DailyFrequency) {
        if ($DailyRetentionType -eq "Weekly") {
            $RetentionUnit = "WEEKS"
        } else {
            $RetentionUnit = "DAYS"
        }
        $dailySchedule = New-RscSlaSnapshotSchedule -Type Daily -Frequency $DailyFrequency -Retention $DailyRetention -RetentionUnit $RetentionUnit
        $RscParams.Add("DailySchedule",$dailySchedule)
    }
    if ($WeeklyFrequency) {
        if ($DayOfWeek) {
            $DayToTakeSnap = $DayOfWeek.toUpper()
        } else {
            $DayToTakeSnap = "MONDAY"
        }
        $weeklySchedule = New-RscSlaSnapshotSchedule -Type Weekly -Frequency $WeeklyFrequency -Retention $WeeklyRetention -DayOfWeek $DayToTakeSnap -RetentionUnit WEEKS
        Write-Host "Adding weekly"
        $RscParams.Add("WeeklySchedule",$weeklySchedule)
    }
    if ($MonthlyFrequency) {
        if ($DayOfMonth -eq "FirstDay") {
            $DayToTakeSnap = "FIRST_DAY"
        } elseif ($DayOfMonth -eq "Fifteenth") {
            $DayToTakeSnap = "FIFTEENTH"
        } else {
            $DayToTakeSnap = "LAST_DAY"
        }
        if ($MonthlyRetentionType -eq "Quarterly") {
            $RetentionUnit = "QUARTERS"
        } elseif ($MonthlyRetentionType -eq "Yearly") {
            $RetentionUnit = "YEARS"
        } else {
            $RetentionUnit = "MONTHS"
        }
        $monthlySchedule = New-RscSlaSnapshotSchedule -Type Monthly -Frequency $MonthlyFrequency -Retention $MonthlyRetention -DayOfMonth $DayToTakeSnap -RetentionUnit $RetentionUnit
        $RscParams.Add("MonthlySchedule",$monthlySchedule)
    }
    if ($QuarterlyFrequency) {
        if ($DayOfQuarter -eq "FirstDay") {
            $DayToTakeSnap = "FIRST_DAY"
        } else {
            $DayToTakeSnap = "LAST_DAY"
        }
        
        if ($FirstQuarterStartMonth) {
            $QuarterStartMonth = $FirstQuarterStartMonth.toUpper()
        } else {
            $QuarterStartMonth = "JANUARY"
        }
        if ($QuarterlyRetentionType -eq "Yearly") {
            $RetentionUnit = "YEARS"
        } else {
            $RetentionUnit = "QUARTERS"
        }
        $quarterlySchedule = New-RscSlaSnapshotSchedule -Type Quarterly -Frequency $QuarterlyFrequency -Retention $QuarterlyRetention -DayOfQuarter $DayToTakeSnap -RetentionUnit $RetentionUnit -QuarterStartMonth $QuarterStartMonth
        $RscParams.Add("QuarterlySchedule",$quarterlySchedule)
    }
    if ($YearlyFrequency) {
        $RetentionUnit = "YEARS"
        if ($YearStartMonth) {
            $YearStart = [RubrikSecurityCloud.Types.Month] $YearStartMonth.toUpper()
        } else {
            $YearStart = [RubrikSecurityCloud.Types.Month] "JANUARY"
        }
        if ($DayOfYear -eq "FirstDay") {
            $DayYear = "FIRST_DAY"
        } else {
            $DayYear = "LAST_DAY"
        }
        $yearlySchedule = New-RscSlaSnapshotSchedule -Type Yearly -Frequency $YearlyFrequency -Retention $YearlyRetention -RetentionUnit $RetentionUnit -YearStartMonth $YearStart -DayOfYear $DayYear
        $RscParams.Add("YearlySchedule",$yearlySchedule)
    }

    $RscParams.Add("ObjectType","VSPHERE_OBJECT_TYPE")
    $response = New-RscSla @RscParams
    return $response
}