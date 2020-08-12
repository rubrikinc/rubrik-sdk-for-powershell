---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubriknutanixcluster
schema: 2.0.0
---

# Update-RubrikNutanixCluster

## SYNOPSIS
Connects to Rubrik to refresh the metadata for the specified Nutanix cluster

## SYNTAX

```
Update-RubrikNutanixCluster [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Update-RubrikNutanixCluster cmdlet will refresh all Nutanix metadata known to the connected Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNutanixCluster -Name 'nutanix.domain.local' | Update-RubrikNutanixCluster
```

This will refresh the Nutanix metadata on the currently connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikNutanixCluster | Update-RubrikNutanixCluster
```

This will refresh the Nutanix metadata for all connected Nutanix instances on the currently connected Rubrik cluster

## PARAMETERS

### -id
Nutanix Cluster id value from the Rubrik Cluster

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubriknutanixcluster](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubriknutanixcluster)

