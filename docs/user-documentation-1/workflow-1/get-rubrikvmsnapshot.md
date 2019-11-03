---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'http://rubrikinc.github.io/rubrik-sdk-for-powershell/'
schema: 2.0.0
---

# Get-RubrikVMSnapshot

## SYNOPSIS

Retrieves details on one or more virtual machines known to a Rubrik cluster

## SYNTAX

```text
Get-RubrikVMSnapshot [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikVMSnapshot cmdlet is used to pull a detailed information from a VM snapshot

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikVMSnapshot -id 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27'
```

This will return details on the specific snapshot.

## PARAMETERS

### -id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Pierre Flammer for community usage Twitter: @PierreFlammer

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

