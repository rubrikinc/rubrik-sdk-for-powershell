---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabase.html
schema: 2.0.0
---

# Restore-RubrikDatabase

## SYNOPSIS
Connects to Rubrik and restores a MSSQL database

## SYNTAX

### Recovery_timestamp
```
Restore-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-TimestampMs <Int64>] [-FinishRecovery]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Recovery_DateTime
```
Restore-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-RecoveryDateTime <DateTime>] [-FinishRecovery]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Recovery_LSN
```
Restore-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-RecoveryLSN <String>] [-FinishRecovery]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Restore-RubrikDatabase command will request a database restore from a Rubrik Cluster to a MSSQL instance.
This
is an inplace restore, meaning it will overwrite the existing asset.

## EXAMPLES

### EXAMPLE 1
```
Restore-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -FinishRecovery -maxDataStreams 4 -timestampMs 1492661627000
```

Restore database to declared epoch ms timestamp.

### EXAMPLE 2
```
Restore-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -maxDataStreams 1 -FinishRecovery
```

Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database.

### EXAMPLE 3
```
Get-RubrikDatabase -Name db01 | Restore-RubrikDatabase -FinishRecovery -maxDataStreams 6 -timestampMs 3492661627000
```

Restore using the pipeline to get the database ID.

## PARAMETERS

### -Id
Rubrik identifier of database to be exported

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MaxDataStreams
Number of parallel streams to copy data

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimestampMs
Recovery Point desired in the form of Epoch with Milliseconds

```yaml
Type: Int64
Parameter Sets: Recovery_timestamp
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecoveryDateTime
Recovery Point desired in the form of DateTime value

```yaml
Type: DateTime
Parameter Sets: Recovery_DateTime
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecoveryLSN
Recovery Point desired in the form of an LSN (Log Sequence Number)

```yaml
Type: String
Parameter Sets: Recovery_LSN
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FinishRecovery
If FinishRecover is true, fully recover the database

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
Position: Named
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
Position: Named
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
Written by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabase.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabase.html)

