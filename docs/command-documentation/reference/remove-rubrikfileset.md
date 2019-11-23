---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikFileset
schema: 2.0.0
---

# Remove-RubrikFileset

## SYNOPSIS

Delete a fileset by specifying the fileset ID

## SYNTAX

```text
Remove-RubrikFileset [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Remove-RubrikFileset cmdlet is used to remove a fileset registered with the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikFileset -Name 'C_Drive' | Remove-RubrikHost
```

This will remove any fileset that matches the name "C\_Drive"

### EXAMPLE 2

```text
Remove-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
```

This will specifically remove the fileset id matching "Fileset:::111111-2222-3333-4444-555555555555"

## PARAMETERS

### -id

The Rubrik ID value of the fileset

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

Written by Chris Wahl for community usage Twitter: @ChrisWahl GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikFileset](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Remove-RubrikFileset)

