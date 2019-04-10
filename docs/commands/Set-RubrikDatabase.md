---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikDatabase.html
schema: 2.0.0
---

# Set-RubrikDatabase

## SYNOPSIS
Sets Rubrik database properties

## SYNTAX

### preBackupScript
```
Set-RubrikDatabase [-id <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-PreScriptPath <String>] [-PreScriptErrorAction <String>] [-PreTimeoutMs <Int32>]
 [-DisablePreBackupScript] [-MaxDataStreams <Int32>] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### postBackupScript
```
Set-RubrikDatabase [-id <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-PostScriptPath <String>] [-PostScriptErrorAction <String>] [-PostTimeoutMs <Int32>]
 [-DisablePostBackupScript] [-MaxDataStreams <Int32>] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Explicit
```
Set-RubrikDatabase [-id <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-MaxDataStreams <Int32>] [-SLAID <String>] [-SLA <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikDatabase cmdlet is used to update certain settings for a Rubrik database.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -LogBackupFrequencyInSeconds 900
```

Set the target database's log backup interval to 15 minutes (900 seconds)

### EXAMPLE 2
```
Get-RubrikDatabase -HostName Foo -Instance MSSQLSERVER | Set-RubrikDatabase -SLA 'Silver' -CopyOnly
```

Set all databases on host FOO to use SLA Silver and be copy only.

### EXAMPLE 3
```
$RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
```

Set-RubrikDatabase -id $RubrikDatabase.id -PreScriptPath "c:\temp\test.bat" -PreScriptErrorAction "continue" -PreTimeoutMs 300 

Set a script to run before a Rubrik Backup runs against the database

### EXAMPLE 4
```
$RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
```

Set-RubrikDatabase -id $RubrikDatabase.id -PostScriptPath "c:\temp\test.bat" -PostScriptErrorAction "continue" -PostTimeoutMs 300 

Set a script to run after a Rubrik Backup runs against the database

### EXAMPLE 5
```
$RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
```

Set-RubrikDatabase -id $RubrikDatabase.id -DisablePreBackupScript 

Remove a script from running before a Rubrik Backup

### EXAMPLE 6
```
$RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
```

Set-RubrikDatabase -id $RubrikDatabase.id -DisablePostBackupScript 

Remove a script from running after a Rubrik Backup

## PARAMETERS

### -id
Rubrik's database id value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LogBackupFrequencyInSeconds
Number of seconds between log backups if db is in FULL or BULK_LOGGED
NOTE: Default of -1 is used to get around ints defaulting as 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogRetentionHours
Number of hours backups will be retained in Rubrik
NOTE: Default of -1 is used to get around ints defaulting as 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### -PreScriptPath
{{ Fill PreScriptPath Description }}

```yaml
Type: String
Parameter Sets: preBackupScript
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreScriptErrorAction
{{ Fill PreScriptErrorAction Description }}

```yaml
Type: String
Parameter Sets: preBackupScript
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreTimeoutMs
{{ Fill PreTimeoutMs Description }}

```yaml
Type: Int32
Parameter Sets: preBackupScript
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisablePreBackupScript
{{ Fill DisablePreBackupScript Description }}

```yaml
Type: SwitchParameter
Parameter Sets: preBackupScript
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostScriptPath
{{ Fill PostScriptPath Description }}

```yaml
Type: String
Parameter Sets: postBackupScript
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostScriptErrorAction
{{ Fill PostScriptErrorAction Description }}

```yaml
Type: String
Parameter Sets: postBackupScript
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostTimeoutMs
{{ Fill PostTimeoutMs Description }}

```yaml
Type: Int32
Parameter Sets: postBackupScript
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisablePostBackupScript
{{ Fill DisablePostBackupScript Description }}

```yaml
Type: SwitchParameter
Parameter Sets: postBackupScript
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxDataStreams
Number of max data streams Rubrik will use to back up the database
NOTE: Default of -1 is used to get around ints defaulting as 0

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -1
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID
SLA Domain ID for the database

```yaml
Type: String
Parameter Sets: (All)
Aliases: ConfiguredSlaDomainId

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
The SLA Domain name in Rubrik

```yaml
Type: String
Parameter Sets: SLA_Explicit
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikDatabase.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikDatabase.html)

