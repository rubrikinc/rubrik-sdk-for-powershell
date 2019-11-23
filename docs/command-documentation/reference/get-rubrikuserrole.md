---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUserRole
schema: 2.0.0
---

# Get-RubrikUserRole

## SYNOPSIS

Gets information around a users role

## SYNTAX

```text
Get-RubrikUserRole [-Id] <String[]> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikUserRole cmdlet is used retrieve information and authorizations around a users role within the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikUserRole -id 'User:::1111-2222-3333'
```

Retrieves the role information for the user account with the specified id.

### EXAMPLE 2

```text
Get-RubrikUser -Username 'jdoe' | Get-RubrikUserRole
```

Retrieves the role information for the user with a username of 'jdoe'

## PARAMETERS

### -Id

User ID

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: principals

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUserRole](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUserRole)

