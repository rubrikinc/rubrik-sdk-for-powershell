---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSNMPSetting
schema: 2.0.0
---

# Get-RubrikSNMPSetting

## SYNOPSIS

Connects to Rubrik and retrieves the SNMP settings.

## SYNTAX

```text
Get-RubrikSNMPSetting [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikSNMPSetting cmdlet will retrieve the SNMP settings configured within a Rubrik Cluster

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikSNMPSetting
```

This will return the details of the SNMP settings configured within the Rubrik cluster

## PARAMETERS

### -Server

Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
Default value: $global:RubrikConnection.api
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSNMPSetting](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSNMPSetting)

