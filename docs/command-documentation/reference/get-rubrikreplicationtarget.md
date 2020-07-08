---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreplicationtarget
schema: 2.0.0
---

# Get-RubrikReplicationTarget

## SYNOPSIS
Connects to Rubrik and retrieves summaries of all replication target clusters

## SYNTAX

### Query (Default)
```
Get-RubrikReplicationTarget [[-targetClusterName] <String>] [-DetailedObject] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikReplicationTarget [-Id] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikReplicationTarget cmdlet will retrieve summaries of all of the clusters configured as a replication target

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikReplicationTarget
```

This will return the details of all replication targets configured on the Rubrik cluster

### EXAMPLE 2
```
Get-RubrikReplicationTarget -Name 'cluster.domain.local'
```

This will return the most common details of the replication target named 'cluster.domain.local' configured on the Rubrik cluster

### EXAMPLE 3
```
Get-RubrikReplicationTarget -Name 'cluster.domain.local' -DetailedObject
```

This will return all of the the details of the replication target named 'cluster.domain.local' configured on the Rubrik cluster

### EXAMPLE 4
```
Get-RubrikReplicationTarget -id '11111-22222-33333'
```

This will return the details of the replication target with an id of '11111-22222-33333' configured on the Rubrik cluster

## PARAMETERS

### -Id
Replication target ID

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

### -targetClusterName
Replication target Cluster Name

```yaml
Type: String
Parameter Sets: Query
Aliases: Name

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed replication target object, the default behavior of the API is to only retrieve a subset of the full replication target object unless we query directly by ID.
Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

```yaml
Type: SwitchParameter
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: False
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreplicationtarget](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreplicationtarget)

