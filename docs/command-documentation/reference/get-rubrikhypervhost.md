---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervhost
schema: 2.0.0
---

# Get-RubrikHyperVHost

## SYNOPSIS
Connects to Rubrik and retrieves a list of HyperV Hosts registered

## SYNTAX

### Query (Default)
```
Get-RubrikHyperVHost [[-Name] <String>] [-server <String>] [-PrimaryClusterID <String>] [-api <String>]
 [<CommonParameters>]
```

### ID
```
Get-RubrikHyperVHost [-id] <String> [-server <String>] [-PrimaryClusterID <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHyperVHost cmdlet will retrieve all of the registered HyperV Hosts within the authenticated Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHyperVHost
```

This will return a listing of all of the HyperV Hosts known to the connected Rubrik cluster

Get-RubrikHyperVHost -PrimarClusterId local
This will return a listing of all of the HyperV Hosts whose primary cluster is that of the connected Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikHyperVHost -Name 'hyperv01'
```

This will return a listing of all of the HyperV Hosts named 'hyperv01' registered with the connected Rubrik cluster

## PARAMETERS

### -id
HyperV Host Id

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
HyperV Host Name

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -server
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

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_cluster_id

Required: False
Position: Named
Default value: None
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervhost](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervhost)

