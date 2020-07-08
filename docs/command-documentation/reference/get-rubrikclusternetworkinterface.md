---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusternetworkinterface
schema: 2.0.0
---

# Get-RubrikClusterNetworkInterface

## SYNOPSIS
Connects to Rubrik and retrieves the network interface details from member nodes of a Rubrik cluster.

## SYNTAX

```
Get-RubrikClusterNetworkInterface [[-interface] <String>] [-Node <String>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikClusterNetworkInterface cmdlet will retrieve the network interface details from nodes connected to a Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikClusterNetworkInterface
```

This will return the details of all network interfaces on all nodes within the Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikClusterNetworkInterface -Interface 'bond0'
```

This will return the details of the 'bond0' interface on all nodes within the Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikClusterNetworkInterface -Node 'Node01'
```

This will return the details of the network interfaces on the node with the id of 'Node01'

## PARAMETERS

### -interface
Interface name to query

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Node
Node id to filter results on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusternetworkinterface](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikclusternetworkinterface)

