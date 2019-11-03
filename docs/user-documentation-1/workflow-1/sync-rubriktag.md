---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikTag.html
schema: 2.0.0
---

# Sync-RubrikTag

## SYNOPSIS

Connects to Rubrik and creates a vSphere tag for each SLA Domain

## SYNTAX

```text
Sync-RubrikTag [-Category] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION

The Sync-RubrikTag cmdlet will query Rubrik for all of the existing SLA Domains, and then create a tag for each one

## EXAMPLES

### EXAMPLE 1

```text
Sync-RubrikTag -vCenter 'vcenter1.demo' -Category 'Rubrik'
```

This will validate or create a vSphere Category named Rubrik along with a Tag for each SLA Domain found in Rubrik

## PARAMETERS

### -Category

The vSphere Category name for the Rubrik SLA Tags

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

Written by Chris Wahl for community usage Twitter: @ChrisWahl GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikTag.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikTag.html)

