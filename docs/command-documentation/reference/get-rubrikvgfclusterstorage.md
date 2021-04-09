---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfclusterstorage
schema: 2.0.0
---

# Get-RubrikVgfClusterStorage

## SYNOPSIS
Returns cluster free space in the case of Volume Group format upgrade

## SYNTAX

```
Get-RubrikVgfClusterStorage [[-name] <String>] [-VGList <String[]>] [-NamePrefix <String>] [-hostname <String>]
 [-HostnamePrefix <String>] [-Relic] [-SLA <String>] [-PrimaryClusterID <String>] [-id <String>]
 [-SLAID <String>] [-FailedLastSnapshot] [-SetToUpgrade] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVgfClusterStorage cmdlet is used to return projected space consumption
on any number of volume groups if they are migrated to use the new format, and the
cluster free space before and after the migration.
If no Volume Group ID or list of
ID is given, it will report the projected space consumption of migrating all Volume
Groups that are currently using the old format.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVgfClusterStorage -VGList VolumeGroup:::e0a04776-ab8e-45d4-8501-8da658221d74, VolumeGroup:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will return projected space consumption on volume groups within the given Volume Group ID list, and cluster free space before and after migration.

### EXAMPLE 2
```
Get-RubrikVgfClusterStorage
```

This will return projected space consumption of migrating all old-format volume groups on the Rubrik cluster, and cluster free space before and after migration.

### EXAMPLE 3
```
Get-RubrikVgfClusterStorage -Hostname 'Server1'
```

This will return projected space consumption of migrating all old-format volume groups from host "Server1", and cluster free space before and after migration.

### EXAMPLE 4
```
Get-RubrikVgfClusterStorage -Hostname 'Server1' -SLA Gold
```

This will return projected space consumption of migrating all old-format volume groups of "Server1" that are protected by the Gold SLA Domain, and cluster free space before and after migration.

### EXAMPLE 5
```
Get-RubrikVgfClusterStorage -Relic
```

This will return projected space consumption of migrating all old-format, removed volume groups that were formerly protected by Rubrik, and cluster free space before and after migration.

### EXAMPLE 6
```
Get-RubrikVgfClusterStorage -FailedLastSnapshot
```

This will return projected space consumption of migrating all old-format volume groups that needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format, and cluster free space before and after migration.

### EXAMPLE 7
```
Get-RubrikVgfClusterStorage -UsedFastVhdx false
```

This will return projected space consumption on volume groups that did not use fast VHDX format in the latest snapshot.

### EXAMPLE 8
```
Get-RubrikVgfClusterStorage -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
```

This will return projected space consumption for the specified VolumeGroup ID, and 0 if this Volume Group uses fast VHDX format (no need for migration).

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

### -VGList
List of Volume Group IDs

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePrefix
Prefix of Volume Group names

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

### -HostnamePrefix
Prefix of host names

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
Filter the report information based on the primarycluster_id of the primary Rubrik cluster.
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

### -FailedLastSnapshot
Filter the report based on whether a Volume Group needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: NeedsMigration

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetToUpgrade
Filter the report based on whether a Volume Group is set to take a full snapshot on the next backup.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ForceFull

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
Written by Feng Lu for community usage
github: fenglu42

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfclusterstorage](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfclusterstorage)

