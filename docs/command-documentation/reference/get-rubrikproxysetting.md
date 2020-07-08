---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikproxysetting
schema: 2.0.0
---

# Get-RubrikProxySetting

## SYNOPSIS
Retrieves a Rubrik Cluster proxy config

## SYNTAX

```
Get-RubrikProxySetting [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikProxySetting cmdlet will retrieve proxy configuration information for the cluster nodes.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikProxySetting
```

This will return the proxy information for the node currently connected to

### EXAMPLE 2
```
Get-RubrikNode | Get-RubrikProxySetting
```

This will return the proxy information for all nodes connected to the current Rubrik Cluster

## PARAMETERS

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: ipAddress

Required: False
Position: 1
Default value: $global:RubrikConnection.server
Accept pipeline input: True (ByPropertyName)
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikproxysetting](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikproxysetting)

