---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppRecoverOptions
schema: 2.0.0
---

# Get-RubrikVAppRecoverOptions

## SYNOPSIS

Retrieves instant recovery options a vCD vApp known to a Rubrik cluster

## SYNTAX

```text
Get-RubrikVAppRecoverOptions [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikVAppRecoverOptions cmdlet is used to retrieve instant recovery options for a vCD vApp known to a Rubrik cluster

## EXAMPLES

### EXAMPLE 1

```text
$SnapshotID = (Get-RubrikVApp -Name 'vApp01' | Get-RubrikSnapshot -Latest).id
```

Get-RubrikVAppRecoverOptions -id $SnapshotID This will return recovery options on the specific snapshot.

## PARAMETERS

### -id

Snapshot ID of the vApp to retrieve options for

```yaml
Type: String
Parameter Sets: (All)
Aliases: snapshot_id

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

Written by Matt Elliott for community usage Twitter: @NetworkBrouhaha Github: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppRecoverOptions](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppRecoverOptions)

