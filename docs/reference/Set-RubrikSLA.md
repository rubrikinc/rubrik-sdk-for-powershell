---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikSLA.html
schema: 2.0.0
---

# Set-RubrikSLA

## SYNOPSIS
Updates an existing Rubrik SLA Domain

## SYNTAX

```
Set-RubrikSLA [-id] <String> [[-Name] <String>] [[-HourlyFrequency] <Int32>] [[-HourlyRetention] <Int32>]
 [[-HourlyRetentionType] <String>] [[-DailyFrequency] <Int32>] [[-DailyRetention] <Int32>]
 [[-DailyRetentionType] <String>] [[-WeeklyFrequency] <Int32>] [[-WeeklyRetention] <Int32>]
 [[-DayOfWeek] <String>] [[-MonthlyFrequency] <Int32>] [[-MonthlyRetention] <Int32>] [[-DayOfMonth] <String>]
 [[-MonthlyRetentionType] <String>] [[-QuarterlyFrequency] <Int32>] [[-QuarterlyRetention] <Int32>]
 [[-DayOfQuarter] <String>] [[-FirstQuarterStartMonth] <String>] [[-QuarterlyRetentionType] <String>]
 [[-YearlyFrequency] <Int32>] [[-YearlyRetention] <Int32>] [[-DayOfYear] <String>] [[-YearStartMonth] <String>]
 [-AdvancedConfig] [[-BackupStartHour] <Int32>] [[-BackupStartMinute] <Int32>]
 [[-BackupWindowDuration] <Int32>] [[-FirstFullBackupStartHour] <Int32>]
 [[-FirstFullBackupStartMinute] <Int32>] [[-FirstFullBackupDay] <String>]
 [[-FirstFullBackupWindowDuration] <Int32>] [[-Frequencies] <Object[]>] [[-AdvancedFreq] <Object[]>]
 [[-BackupWindows] <Object[]>] [[-FirstFullBackupWindows] <Object[]>] [[-Server] <String>] [[-api] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikSLA cmdlet will update an existing SLA Domain with specified parameters.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikSLA -id e4d121af-5611-496a-bb8d-57ba46443e94 -Name Gold -HourlyFrequency 12 -HourlyRetention 5
```

This will update the SLA Domain named "Gold" to take a snapshot every 12 hours and keep those for 5 days.
All other existing parameters will be reset.

### EXAMPLE 2
```
Get-RubrikSLA -Name Gold | Set-RubrikSLA -HourlyFrequency 4 -HourlyRetention 3
```

This will update the SLA Domain named "Gold" to take a snapshot every 4 hours and keep those hourly snapshots for 3 days,
while keeping all other existing parameters.

### EXAMPLE 3
```
Get-RubrikSLA -Name Gold | Set RubrikSLA -AdvancedConfig -HourlyFrequency 4 -HourlyRetention 3 -WeeklyFrequency 1 -WeeklyRetention 4 -DayOfWeek Friday
```

This will update the SLA Domain named "Gold" to take a snapshot every 4 hours and keep those hourly snapshots for 3 days
while also keeping one snapshot per week for 4 weeks, created on Fridays.
All other existing parameters will remain as they were.

### EXAMPLE 4
```
Get-RubrikSLA -Name Gold | Set-RubrikSLA -BackupStartHour 22 -BackupStartMinute 00 -BackupWindowDuration 8
```

This will update the SLA Domain named "Gold" to take snapshots between 22:00PM and 6:00AM, while keeping all other existing parameters.

### EXAMPLE 5
```
Get-RubrikSLA -Name Gold | Set-RubrikSLA -FirstFullBackupStartHour 21 -FirstFullBackupStartMinute 30 -FirstFullBackupWindowDuration 57 -FirstFullBackupDay Friday
```

This will update the SLA Domain named "Gold" to take the first full snapshot between Friday 21:30PM and Monday 6:30AM, while keeping all other existing parameters.

### EXAMPLE 6
```
Get-RubrikSLA -Name Gold | Set-RubrikSLA -AdvancedConfig
```

This will update the SLA Domain named "Gold" to only enable Advanced Configuration

## PARAMETERS

### -id
SLA id value from the Rubrik Cluster

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
SLA Domain Name

```yaml
Type: String
Parameter Sets: (All)
Aliases: SLA

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HourlyFrequency
Hourly frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -HourlyRetention
Number of days or weeks to retain the hourly snapshots.
For CDM versions prior to 5.0 this value must be set in days

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -HourlyRetentionType
Retention type to apply to hourly snapshots when $AdvancedConfig is used.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Daily
Accept pipeline input: False
Accept wildcard characters: False
```

### -DailyFrequency
Daily frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DailyRetention
Number of days or weeks to retain the daily snapshots.
For CDM versions prior to 5.0 this value must be set in days

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DailyRetentionType
Retention type to apply to daily snapshots when $AdvancedConfig is used.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: Daily
Accept pipeline input: False
Accept wildcard characters: False
```

### -WeeklyFrequency
Weekly frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -WeeklyRetention
Number of weeks to retain the weekly snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayOfWeek
Day of week for the weekly snapshots when $AdvancedConfig is used.
The default is Saturday.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: Saturday
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthlyFrequency
Monthly frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthlyRetention
Number of months, quarters or years to retain the monthly backups.
For CDM versions prior to 5.0, this value must be set in years

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayOfMonth
Day of month for the monthly snapshots when $AdvancedConfig is used.
The default is the last day of the month.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: LastDay
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthlyRetentionType
Retention type to apply to monthly snapshots.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: Monthly
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuarterlyFrequency
Quarterly frequency to take snapshots.
Does not apply to CDM versions prior to 5.0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuarterlyRetention
Number of quarters or years to retain the monthly snapshots.
Does not apply to CDM versions prior to 5.0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayOfQuarter
Day of quarter for the quarterly snapshots when $AdvancedConfig is used.
The default is the last day of the quarter.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: LastDay
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstQuarterStartMonth
Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used.
The default is January.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: January
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuarterlyRetentionType
Retention type to apply to quarterly snapshots.
The default is Quarterly.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: Quarterly
Accept pipeline input: False
Accept wildcard characters: False
```

### -YearlyFrequency
Yearly frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -YearlyRetention
Number of years to retain the yearly snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DayOfYear
Day of year for the yearly snapshots when $AdvancedConfig is used.
The default is the last day of the year.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: LastDay
Accept pipeline input: False
Accept wildcard characters: False
```

### -YearStartMonth
Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used.
The default is January.
Does not apply to CDM versions prior to 5.0

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 24
Default value: January
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdvancedConfig
Whether to turn advanced SLA configuration on or off.
Does not apply to CDM versions prior to 5.0

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupStartHour
Hour from which backups are allowed to run.
Uses the 24-hour clock

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 25
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupStartMinute
Minute of hour from which backups are allowed to run

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 26
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupWindowDuration
Number of hours during which backups are allowed to run

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 27
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstFullBackupStartHour
Hour from which the first full backup is allowed to run.
Uses the 24-hour clock

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 28
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstFullBackupStartMinute
Minute of hour from which the first full backup is allowed to run

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 29
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstFullBackupDay
{{ Fill FirstFullBackupDay Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 30
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstFullBackupWindowDuration
Number of hours during which the first full backup is allowed to run

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 31
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Frequencies
Retrieves frequencies from Get-RubrikSLA via the pipeline

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 32
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AdvancedFreq
Retrieves the advanced UI configuration parameters from Get-RubrikSLA via the pipeline

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: advancedUiConfig

Required: False
Position: 33
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BackupWindows
Retrieves the allowed backup windows from Get-RubrikSLA via the pipeline

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: allowedBackupWindows

Required: False
Position: 34
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FirstFullBackupWindows
Retrieves the allowed backup windows for the first full backup from Get-RubrikSLA via the pipeline

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: firstFullAllowedBackupWindows

Required: False
Position: 35
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 36
Default value: $global:RubrikConnection.server
Accept pipeline input: False
Accept wildcard characters: False
```

### -api
API version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 37
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pierre-Fran §ois Guglielmi for community usage
Twitter: @pfguglielmi
GitHub: pfguglielmi

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikSLA.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikSLA.html)

