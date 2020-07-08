---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvolumegroup
schema: 2.0.0
---

# Get-RubrikVolumeGroup

## SYNOPSIS
Retrieves details on one or more volume groups known to a Rubrik cluster

## SYNTAX

```
Get-RubrikVolumeGroup [[-name] <String>] [-hostname <String>] [-Relic] [-SLA <String>]
 [-PrimaryClusterID <String>] [-id <String>] [-SLAID <String>] [-DetailedObject] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVolumeGroup cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of volume groups.
By default the 'Includes' property is not populated, unless when querying by ID or by using the -DetailedObject parameter

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVolumeGroup -Hostname 'Server1'
```

This will return details on all volume groups from host "Server1".

### EXAMPLE 2
```
Get-RubrikVolumeGroup -Hostname 'Server1' -SLA Gold
```

This will return details on all volume groups of "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 3
```
Get-RubrikVolumeGroup -Relic
```

This will return all removed volume groups that were formerly protected by Rubrik.

### EXAMPLE 4
```
Get-RubrikVolumeGroup -DetailedObject
```

This will return full details on all volume groups available on the Rubrik Cluster, this query will take longer as multiple API calls are required.
The 'Includes' property will be populated

### EXAMPLE 5
```
Get-RubrikVolumeGroup -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
```

This will return full details on for the specified VolumeGroup ID

## PARAMETERS

### -name
Name of the volume group

```yaml
Type: String
Parameter Sets: (All)
Aliases: VolumeGroup

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -hostname
Filter results by hostname

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

### -Relic
Filter results to include only relic (removed) volume groups

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: is_relic

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
SLA Domain policy assigned to the volume group

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
Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

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

### -id
Volume group id

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

### -SLAID
SLA id value

```yaml
Type: String
Parameter Sets: (All)
Aliases: effective_sla_domain_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed VolumeGroup object, the default behavior of the API is to only retrieve a subset of the full VolumeGroup object unless we query directly by ID.
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
Written by Pierre Flammer for community usage
Twitter: @PierreFlammer

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvolumegroup](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvolumegroup)

