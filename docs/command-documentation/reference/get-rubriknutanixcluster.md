---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixcluster
schema: 2.0.0
---

# Get-RubrikNutanixCluster

## SYNOPSIS
Connects to Rubrik and retrieves the current Nutanix Clusters

## SYNTAX

### Query (Default)
```
Get-RubrikNutanixCluster [[-Name] <String>] [-Hostname <String>] [-PrimaryClusterID <String>]
 [-GetConnectionStatus] [-DetailedObject] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikNutanixCluster [-Id] <String> [-Hostname <String>] [-PrimaryClusterID <String>]
 [-GetConnectionStatus] [-DetailedObject] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikNutanixCluster cmdlet will retrieve the all the Nutanix Cluster settings actively running on the system.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNutanixCluster
```

This will return all the Nutanix Clusters and their associated settings currently known to the Rubrik cluster

### EXAMPLE 2
```
Get-RubrikNutanixCluster -GetConnectionStatus
```

This will return all the Nutanix Clusters and their associated settings, including their connection status which are currently known to the Rubrik cluster

### EXAMPLE 3
```
Get-RubrikNutanixCluster -PrimaryClusterId "local" -Name "ProductionCluster"
```

This will return all the Nutanix Clusters named ProductionCluster currently associated with the cluster in which the API is authenticated to

### EXAMPLE 4
```
Get-RubrikNutanixCluster -Hostname "nutanix.domain.local"
```

This will return all the Nutanix Clusters with a hostname of "nutanix.domain.local" currently known to the Rubrik cluster

## PARAMETERS

### -Id
Nutanix Cluster Id

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
Nutanix Cluster Name

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

### -Hostname
Nutanix Cluster hostname

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

### -GetConnectionStatus
Should the connection status be retrieved.
Retrieving the connection status could adversly affect performance

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: should_get_status

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed Nutanix clusterobject, the default behavior of the API is to only retrieve a subset of the full Nutanix Cluster object unless we query directly by ID.
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixcluster](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixcluster)

