---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Export-RubrikDatabase

## SYNOPSIS
Connects to Rubrik exports a database to a MSSQL instance

## SYNTAX

### Recovery_timestamp
```
Export-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-TimestampMs <Int64>] [-FinishRecovery]
 [-TargetInstanceId <String>] [-TargetDatabaseName <String>] [-Server <String>] [-api <String>]
 [-TargetDataFilePath <String>] [-TargetLogFilePath <String>] [-TargetFilePaths <PSObject[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Recovery_DateTime
```
Export-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-RecoveryDateTime <DateTime>] [-FinishRecovery]
 [-TargetInstanceId <String>] [-TargetDatabaseName <String>] [-Server <String>] [-api <String>]
 [-TargetDataFilePath <String>] [-TargetLogFilePath <String>] [-TargetFilePaths <PSObject[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Export-RubrikDatabase command will request a database export from a Rubrik Cluster to a MSSQL instance

## EXAMPLES

### EXAMPLE 1
```
Export-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -targetInstanceId MssqlInstance:::0085b247-e718-4177-869f-e3ae1f7bb503 -targetDatabaseName ReportServer -finishRecovery -maxDataStreams 4 -timestampMs 1492661627000
```

### EXAMPLE 2
```
Export-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -targetInstanceId $db2.instanceId -targetDatabaseName 'BAR_EXP' -targetFilePaths $targetfiles -maxDataStreams 1
```

Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database.
New file paths are 
in the $targetfiles array.
Each individual file declaration (logicalName, exportPath,newFilename) will be a hashtable, so what gets passed to the
cmdlet is an array of hashtables

$targetfiles = @()
$targetfiles += @{logicalName='BAR_1';exportPath='E:\SQLFiles\Data\BAREXP\'}
$targetfiles += @{logicalName='BAR_LOG';exportPath='E:\SQLFiles\Log\BAREXP\'}

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

### -FinishRecovery
Take database out of recovery mode after export

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

### -TargetInstanceId
Rubrik identifier of MSSQL instance to export to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetDatabaseName
Name to give database upon export

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### -TargetDataFilePath
Simple Mode - Data File Path

```yaml
Type: String
Parameter Sets: (All)
Aliases: DataFilePath

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetLogFilePath
Simple Mode - Data File Path

```yaml
Type: String
Parameter Sets: (All)
Aliases: LogFilePath

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetFilePaths
Advanced Mode - Array of hash tables for file reloaction.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pete Milanese for community usage
Twitter: @pmilano1
GitHub: pmilano1

Modified by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

