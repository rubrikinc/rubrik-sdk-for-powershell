---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppExportOptions
schema: 2.0.0
---

# Get-RubrikVAppExportOptions

## SYNOPSIS

Retrieves export for a vCD vApp known to a Rubrik cluster

## SYNTAX

```text
Get-RubrikVAppExportOptions -id <String> -ExportMode <String> [-TargetVAppID <String>]
 [-TargetOrgVDCID <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikVAppExportOptions cmdlet retrieves export options for a vCD vApp known to a Rubrik cluster

## EXAMPLES

### EXAMPLE 1

```text
$SnapshotID = (Get-RubrikVApp -Name 'vApp01' | Get-RubrikSnapshot -Latest).id
```

Get-RubrikVAppExportOptions -id $SnapshotID -ExportMode 'ExportToNewVapp' This returns available export options for the specific snapshot.

## PARAMETERS

### -id

Snapshot ID of the vApp to retrieve options for

```yaml
Type: String
Parameter Sets: (All)
Aliases: snapshot_id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExportMode

Specifies whether export should use the existing vApp or create a new vApp. Valid values are ExportToNewVapp or ExportToTargetVapp

```yaml
Type: String
Parameter Sets: (All)
Aliases: export_mode

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetVAppID

ID of target vApp

```yaml
Type: String
Parameter Sets: (All)
Aliases: target_vapp_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetOrgVDCID

ID of target vApp

```yaml
Type: String
Parameter Sets: (All)
Aliases: target_org_vdc_id

Required: False
Position: Named
Default value: None
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
Position: Named
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
Position: Named
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Matt Elliott for community usage Twitter: @NetworkBrouhaha GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppExportOptions](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikVAppExportOptions)

