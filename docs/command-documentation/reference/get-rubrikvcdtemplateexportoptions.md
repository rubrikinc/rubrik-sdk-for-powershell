---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'http://rubrikinc.github.io/rubrik-sdk-for-powershell/'
schema: 2.0.0
---

# Get-RubrikVCDTemplateExportOptions

## SYNOPSIS

Retrieves export options for a vCD Template known to a Rubrik cluster

## SYNTAX

```text
Get-RubrikVCDTemplateExportOptions [-id] <String> [[-catalogid] <String>] [[-name] <String>]
 [[-orgvdcid] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikVCDTemplateExportOptions cmdlet retrieves export options for a vCD Template known to a Rubrik cluster

## EXAMPLES

### EXAMPLE 1

```text
$SnapshotID = (Get-RubrikVApp -Name 'vAppTemplate01' | Get-RubrikSnapshot -Latest).id
```

Get-RubrikVCDTemplateExportOptions -id $SnapshotID -catalogid 'VcdCatalog:::01234567-8910-1abc-d435-0abc1234d567' -Name 'vAppTemplate01-export' This will return export options details on the specific snapshot.

## PARAMETERS

### -id

Snapshot ID of the vCD Template to retrieve options for

```yaml
Type: String
Parameter Sets: (All)
Aliases: snapshot_id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -catalogid

ID of target catalog. Defaults to the existing catalog.

```yaml
Type: String
Parameter Sets: (All)
Aliases: catalog_id

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -name

Name of the newly exported vCD Template. Defaults to \[TemplateName\]-Export

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -orgvdcid

Org vDC ID to export the vCD Template to. This should be an Org vDC in the same vCD Org where the target catalog exists.

```yaml
Type: String
Parameter Sets: (All)
Aliases: org_vdc_id

Required: False
Position: 4
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
Position: 5
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
Position: 6
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

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

