---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# New-RubrikDatabaseMount

## SYNOPSIS
Create a new Live Mount from a protected database

## SYNTAX

### Recovery_timestamp
```
New-RubrikDatabaseMount -id <String> [-TargetInstanceId <String>] [-MountedDatabaseName <String>]
 [-TimestampMs <Int64>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
```

### Recovery_DateTime
```
New-RubrikDatabaseMount -id <String> [-TargetInstanceId <String>] [-MountedDatabaseName <String>]
 [-RecoveryDateTime <DateTime>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The New-RubrikDatabaseMount cmdlet is used to create a Live Mount (clone) of a protected database and run it in an existing database environment.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-RubrikDatabaseMount -id $db.id -targetInstanceId $db.instanceId -mountedDatabaseName 'BAR-LM' -recoveryDateTime (Get-date (Get-RubrikDatabase -id $db.id).latestRecoveryPoint)
```

Creates a new database mount named BAR on the same instance as the source database, using the most recent recovery time for the database. 

$db=Get-RubrikDatabase -HostName FOO -Instance MSSQLSERVER -Database BAR

## PARAMETERS

### -id
Rubrik id of the database

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

### -TargetInstanceId
ID of Instance to use for the mount

```yaml
Type: String
Parameter Sets: (All)
Aliases: InstanceId

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MountedDatabaseName
Name of the mounted database

```yaml
Type: String
Parameter Sets: (All)
Aliases: DatabaseName, MountName

Required: False
Position: Named
Default value: None
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

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal for community usage from New-RubrikMount
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

