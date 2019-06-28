---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/
schema: 2.0.0
---

# Get-RubrikDatabaseRecoverableRange

## SYNOPSIS
Retrieves recoverable ranges for SQL Server databases.

## SYNTAX

```
Get-RubrikDatabaseRecoverableRange [[-id] <String>] [[-StartDateTime] <DateTime>] [[-EndDateTime] <DateTime>]
 [[-AfterTime] <String>] [[-BeforeTime] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikDatabaseRecoverableRange cmdlet retrieves recoverable ranges for
SQL Server databases protected by Rubrik.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange
```

Retrieve all recoverable ranges for the BAR database on the FOO host.

### EXAMPLE 2
```
Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -BeforeTime '2018-03-31T00:00:00.000Z'
```

Retrieve all recoverable ranges for the BAR database on the FOO host after '2018-03-31T00:00:00.000Z'.

### EXAMPLE 3
```
Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -EndTime '2018-04-01'
```

Retrieve all recoverable ranges for the BAR database on the FOO host before '2018-04-01' after it's converted to UTC.

## PARAMETERS

### -id
Rubrik's database id value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StartDateTime
Range Start as datetime

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndDateTime
Range End as datetime

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterTime
After time/Start time of range in ISO8601 format (2016-01-01T01:23:45.678Z)

```yaml
Type: String
Parameter Sets: (All)
Aliases: after_time

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BeforeTime
Before time/end time of range in ISO8601 format (2016-01-01T01:23:45.678Z)

```yaml
Type: String
Parameter Sets: (All)
Aliases: before_time

Required: False
Position: 5
Default value: None
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
Position: 6
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
Position: 7
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

