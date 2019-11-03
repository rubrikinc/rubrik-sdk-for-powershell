---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikReport
schema: 2.0.0
---

# Remove-RubrikReport

## SYNOPSIS
Removes one or more reports created in Rubrik Envision

## SYNTAX

```
Remove-RubrikReport [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikReport cmdlet is used to delete any number of Rubrik Envision reports

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikReport | Remove-RubrikReport -Confirm:$true
```

This will delete all reports and force confirmation for each delete operation

### EXAMPLE 2
```
Get-RubrikReport -Name 'SLA' -Type Custom | Remove-RubrikReport
```

This will delete all custom reports that contain the string "SLA"

### EXAMPLE 3
```
Get-RubrikReport -id '11111111-2222-3333-4444-555555555555' | Remove-RubrikReport -Confirm:$false
```

This will delete the report id "11111111-2222-3333-4444-555555555555" without confirmation

## PARAMETERS

### -id
The Rubrik ID value of the report

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikReport](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikReport)

