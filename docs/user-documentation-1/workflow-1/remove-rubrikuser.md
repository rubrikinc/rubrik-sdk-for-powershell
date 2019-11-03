---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUser.html
schema: 2.0.0
---

# Remove-RubrikUser

## SYNOPSIS

Removes a Rubrik user

## SYNTAX

```text
Remove-RubrikUser [-Id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Remove-RubrikUser cmdlet is used to remove a user from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Remove-RubrikUser -id "11111111-2222-3333-4444-555555555555"
```

This will remove the user matching id "11111111-2222-3333-4444-555555555555".

### EXAMPLE 2

```text
Get-RubrikUser -Username 'john.doe' | Remove-RubrikUser
```

This will remove the user with the matching username of john.doe

## PARAMETERS

### -Id

ID of user to remove.

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

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUser.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUser.html)

