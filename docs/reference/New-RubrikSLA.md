---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSLA.html
schema: 2.0.0
---

# New-RubrikSLA

## SYNOPSIS
Creates a new Rubrik SLA Domain

## SYNTAX

```
New-RubrikSLA [-Name] <String> [[-HourlyFrequency] <Int32>] [[-HourlyRetention] <Int32>]
 [[-HourlyRetentionType] <String>] [[-DailyFrequency] <Int32>] [[-DailyRetention] <Int32>]
 [[-DailyRetentionType] <String>] [[-WeeklyFrequency] <Int32>] [[-WeeklyRetention] <Int32>]
 [[-DayOfWeek] <String>] [[-MonthlyFrequency] <Int32>] [[-MonthlyRetention] <Int32>] [[-DayOfMonth] <String>]
 [[-MonthlyRetentionType] <String>] [[-QuarterlyFrequency] <Int32>] [[-QuarterlyRetention] <Int32>]
 [[-DayOfQuarter] <String>] [[-FirstQuarterStartMonth] <String>] [[-QuarterlyRetentionType] <String>]
 [[-YearlyFrequency] <Int32>] [[-YearlyRetention] <Int32>] [[-DayOfYear] <String>] [[-YearStartMonth] <String>]
 [-AdvancedConfig] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24
```

This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.

### EXAMPLE 2
```
New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
```

This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours
while also keeping one backup per day for 30 days.

## PARAMETERS

### -Name
SLA Domain Name

```yaml
Type: String
Parameter Sets: (All)
Aliases: SLA

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HourlyFrequency
Hourly frequency to take snapshots

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
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
Position: 4
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
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
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
Position: 9
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
Position: 10
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
Position: 11
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
Position: 12
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
Position: 13
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
Position: 14
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
Position: 15
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
Position: 16
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
Position: 17
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
Position: 18
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
Position: 19
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
Position: 20
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
Position: 21
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
Position: 22
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
Position: 23
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

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 24
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
Position: 25
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSLA.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSLA.html)

