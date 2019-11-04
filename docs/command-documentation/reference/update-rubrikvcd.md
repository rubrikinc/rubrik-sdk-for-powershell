---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Update-RubrikVCD
schema: 2.0.0
---

# Update-RubrikVCD

## SYNOPSIS

Connects to Rubrik and refreshes the metadata for the specified vCD Server

## SYNTAX

```text
Update-RubrikVCD [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Update-RubrikVCD cmdlet refreshes all vCD metadata known to the connected Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikVCD -Name 'vcd.domain.local' | Update-RubrikVCD
```

This will refresh the vCD metadata on the currently connected Rubrik cluster

### EXAMPLE 2

```text
Get-RubrikVCD | Update-RubrikVCD
```

This will refresh the vCD metadata for all connected vCD instances on the currently connected Rubrik cluster

## PARAMETERS

### -id

vCD OD value from the Rubrik Cluster

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Matt Eliott for community usage Twitter: @NetworkBrouhaha GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Update-RubrikVCD](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Update-RubrikVCD)

