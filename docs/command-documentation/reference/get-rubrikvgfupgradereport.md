---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfupgradereport
schema: 2.0.0
---

# Get-RubrikVgfUpgradeReport

## SYNOPSIS
Returns projected space consumption of Volume Group format upgrade

## SYNTAX

```
Get-RubrikVgfUpgradeReport [[-name] <String>] [-VGList <String[]>] [-NamePrefix <String>] [-hostname <String>]
 [-HostnamePrefix <String>] [-Relic] [-SLA <String>] [-PrimaryClusterID <String>] [-id <String>]
 [-SLAID <String>] [-FailedLastSnapshot] [-SetToUpgrade] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVgfUpgradeReport cmdlet is used to return the projected space consumption on any number of volume groups if they are migrated to use the new format.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVgfUpgradeReport -VGList VolumeGroup:::e0a04776-ab8e-45d4-8501-8da658221d74, VolumeGroup:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will return projected space consumption on volume groups within the given Volume Group ID list.

### EXAMPLE 2
```
Get-RubrikVgfUpgradeReport
```

This will return projected space consumption on all volume groups on the Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikVgfUpgradeReport -Hostname 'Server1'
```

This will return projected space consumption on all volume groups from host "Server1".

### EXAMPLE 4
```
Get-RubrikVgfUpgradeReport -Hostname 'Server1' -SLA Gold
```

This will return projected space consumption on all volume groups of "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 5
```
Get-RubrikVgfUpgradeReport -Relic
```

This will return projected space consumption on all removed volume groups that were formerly protected by Rubrik.

### EXAMPLE 6
```
Get-RubrikVgfUpgradeReport -FailedLastSnapshot
```

This will return projected space consumption on all volume groups that needs to be migrated to use fast VHDX format since they have failed the latest snapshot using the legacy backup format.

### EXAMPLE 7
```
Get-RubrikVgfUpgradeReport -UsedFastVhdx false
```

This will return projected space consumption on volume groups that did not use fast VHDX format in the latest snapshot.

### EXAMPLE 8
```
Get-RubrikVgfUpgradeReport -Id VolumeGroup:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
```

This will return projected space consumption for the specified VolumeGroup ID

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfupgradereport](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfupgradereport)

