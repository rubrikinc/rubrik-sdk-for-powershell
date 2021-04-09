---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwarehost
schema: 2.0.0
---

# Get-RubrikVMwareHost

## SYNOPSIS
Connects to Rubrik and retrieves a list of ESXi hosts registered

## SYNTAX

```
Get-RubrikVMwareHost [[-Name] <String>] [-id <String>] [-Server <String>] [-PrimaryClusterID <String>]
 [-DetailedObject] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVMwareHost cmdlet will retrieve all of the registered ESXi hosts within the authenticated Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVMwareHost
```

This will return a listing of all of the ESXi hosts known to the connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikVMwareHost -PrimarClusterId local
```

This will return a listing of all of the ESXi hosts whose primary cluster is that of the connected Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikVMwareHost -Name 'esxi01'
```

This will return a listing of all of the ESXi hosts named 'esxi01' registered with the connected Rubrik cluster

### EXAMPLE 4
```
Get-RubrikVMwareHost -Name 'esxi01' -DetailedObject
```

This will return a listing of all of the ESXi hosts named 'esxi01' registered with the connected Rubrik cluster with fully detailed objects

## PARAMETERS

### -Name
ESXi Host Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Datastore id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### -DetailedObject
DetailedObject will retrieved the detailed VMware Host object, the default behavior of the API is to only retrieve a subset of the full VMware Host object unless we query directly by ID.
Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwarehost](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwarehost)

