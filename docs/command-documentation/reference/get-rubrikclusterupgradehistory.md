---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterupgradehistory
schema: 2.0.0
---

# Get-RubrikClusterUpgradeHistory

## SYNOPSIS
Retrieves upgrade history for a given cluster

## SYNTAX

```
Get-RubrikClusterUpgradeHistory [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikClusterUpgradeHistory cmdlet will retrieve upgrade history for a given cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikClusterUpgradeHistory
```

This will return the upgrade history for the currently authenticated cluster.

### EXAMPLE 2
```
Get-RubrikClusterUpgradeHistory -Verbose
```

This will return the upgrade history for the currently authenticated cluster, while displaying verbose information

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
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterupgradehistory](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusterupgradehistory)

