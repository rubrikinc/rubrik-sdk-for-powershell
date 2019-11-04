---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikHost
schema: 2.0.0
---

# New-RubrikHost

## SYNOPSIS

Registers a host with a Rubrik cluster.

## SYNTAX

```text
New-RubrikHost [-Name] <String> [-HasAgent] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The New-RubrikHost cmdlet is used to register a host with the Rubrik cluster. This could be a host leveraging the Rubrik Backup Service or directly as with the case of NAS shares.

## EXAMPLES

### EXAMPLE 1

```text
New-RubrikHost -Name 'Server1.example.com'
```

This will register a host that resolves to the name "Server1.example.com"

### EXAMPLE 2

```text
New-RubrikHost -Name 'NAS.example.com' -HasAgent:$false
```

This will register a host that resolves to the name "NAS.example.com" without using the Rubrik Backup Service In this case, the example host is a NAS share.

## PARAMETERS

### -Name

The IPv4 address of the host or the resolvable hostname of the host

```yaml
Type: String
Parameter Sets: (All)
Aliases: Hostname

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HasAgent

Set to $false to register a host that will be accessed through network shares

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikHost](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikHost)

