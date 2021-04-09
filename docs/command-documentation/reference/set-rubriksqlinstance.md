---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriksqlinstance
schema: 2.0.0
---

# Set-RubrikSQLInstance

## SYNOPSIS
Sets SQL Instance properties

## SYNTAX

### NoSLA_Changes (Default)
```
Set-RubrikSQLInstance [[-id] <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Inherit
```
Set-RubrikSQLInstance [[-id] <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-Inherit] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Unprotected
```
Set-RubrikSQLInstance [[-id] <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-DoNotProtect] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Explicit
```
Set-RubrikSQLInstance [[-id] <String>] [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-SLAID <String>] [-SLA <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikSQLInstance cmdlet is used to update certain settings for a Rubrik SQL instance.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikSQLInstance
```

### EXAMPLE 2
```
Get-RubrikSQLInstance -Hostname RFITZHUGH-SQL | Set-RubrikSQLInstance -Inherit -Verbose -CopyOnly
```

Will update the SLA policy for the RFITZHUGH SQL host to inherit and setting copyOnly to true while displaying verbose information in the console

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
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogBackupFrequencyInSeconds
Number of seconds between log backups if db s are in FULL or BULK_LOGGED
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
Boolean declaration for copy only backups on the instance.

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

### -SLAID
SLA Domain ID for the database

```yaml
Type: String
Parameter Sets: SLA_Explicit
Aliases: ConfiguredSlaDomainId

Required: False
Position: Named
Default value: (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$false)
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

### -DoNotProtect
Removes the SLA Domain assignment

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Unprotected
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inherit
Inherits the SLA Domain assignment from a parent object

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Inherit
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
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriksqlinstance](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriksqlinstance)

