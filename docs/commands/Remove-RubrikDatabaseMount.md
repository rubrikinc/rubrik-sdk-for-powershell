---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabaseMount.html
schema: 2.0.0
---

# Remove-RubrikDatabaseMount

## SYNOPSIS
Connects to Rubrik and removes one or more database live mounts

## SYNTAX

```
Remove-RubrikDatabaseMount [-id] <String> [-Force] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikDatabaseMount cmdlet is used to request the deletion of one or more instant database mounts

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555'
```

This will remove mount id "11111111-2222-3333-4444-555555555555".

### EXAMPLE 2
```
Get-RubrikDatabaseMount | Remove-RubrikDatabaseMount
```

This will remove all mounted databases.

### EXAMPLE 3
```
Get-RubrikDatabaseMount -source_database_name 'BAR' | Remove-RubrikDatabaseMount
```

This will remove any mounts found using the datase name as a base reference.

## PARAMETERS

### -id
The Rubrik ID value of the mount

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

### -Force
Force unmount to deal with situations where host has been moved.

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
Position: 2
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
Position: 3
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabaseMount.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabaseMount.html)

