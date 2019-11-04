---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikSQLInstance
schema: 2.0.0
---

# Set-RubrikSQLInstance

## SYNOPSIS

Sets SQL Instance properties

## SYNTAX

```text
Set-RubrikSQLInstance [-id] <String> [-LogBackupFrequencyInSeconds <Int32>] [-LogRetentionHours <Int32>]
 [-CopyOnly] [-SLAID <String>] [-SLA <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikSQLInstance cmdlet is used to update certain settings for a Rubrik SQL instance.

## EXAMPLES

### EXAMPLE 1

```text
Set-RubrikSQLInstance
```

## PARAMETERS

### -id

Rubrik's database id value

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

### -LogBackupFrequencyInSeconds

Number of seconds between log backups if db s are in FULL or BULK\_LOGGED NOTE: Default of -1 is used to get around ints defaulting as 0

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

Number of hours backups will be retained in Rubrik NOTE: Default of -1 is used to get around ints defaulting as 0

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

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Fal for community usage Twitter: @Mike\_Fal GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikSQLInstance](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikSQLInstance)

