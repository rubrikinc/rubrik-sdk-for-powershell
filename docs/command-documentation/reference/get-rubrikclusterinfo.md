---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterinfo
schema: 2.0.0
---

# Get-RubrikClusterInfo

## SYNOPSIS
Connects to Rubrik and retrieves node information for a given cluster

## SYNTAX

```
Get-RubrikClusterInfo [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikClusterInfo cmdlet will retrieve various information and settings for a given cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikClusterInfo
```

This will return the advanced settings and information around the currently authenticated cluster.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterinfo](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterinfo)

