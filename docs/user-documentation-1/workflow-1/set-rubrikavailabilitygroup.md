---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'http://rubrikinc.github.io/rubrik-sdk-for-powershell/'
schema: 2.0.0
---

# Set-RubrikAvailabilityGroup

## SYNOPSIS

Sets the protection values of an Availability Group

## SYNTAX

```text
Set-RubrikAvailabilityGroup [[-id] <String>] [[-LogBackupFrequencyInSeconds] <Int32>]
 [[-LogRetentionHours] <Int32>] [-CopyOnly] [[-SLA] <String>] [[-SLAID] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikAvailabilityGroup cmdlet is used to set the protetion values of an Availability Group in Rubrik.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD
```

This will set the SLA Domain to GOLD for this Availability Group

### EXAMPLE 2

```text
Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD -LogBackupFrequencyInSeconds 3600 -LogRetentionHours 168
```

This will set the SLA Domain to GOLD for this Availability Group with a log backup frequency of hourly and a retention of 15 days

## PARAMETERS

### -id

Availability Group ID

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

### -LogBackupFrequencyInSeconds

How often we should backup the transaction log

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogRetentionHours

How long should we keep the backup for

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -CopyOnly

Boolean declaration for copy only backups on the database.

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

### -SLA

SLA Domain Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID

SLA Domain ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: configuredSlaDomainId

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Chris Lumnah for community usage Twitter: @lumnah GitHub: clumnah

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

