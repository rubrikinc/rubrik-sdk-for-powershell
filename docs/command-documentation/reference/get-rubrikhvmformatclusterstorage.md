---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatclusterstorage
schema: 2.0.0
---

# Get-RubrikHvmFormatClusterStorage

## SYNOPSIS
Returns cluster free space in the case of Hyper-V Virtual Machine format upgrade

## SYNTAX

```
Get-RubrikHvmFormatClusterStorage [[-name] <String>] [-VMList <String[]>] [-NamePrefix <String>]
 [-hostname <String>] [-HostnamePrefix <String>] [-Relic] [-SLA <String>] [-PrimaryClusterID <String>]
 [-id <String>] [-SLAID <String>] [-SetToUpgrade] [-DisplayReport] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHvmFormatClusterStorage cmdlet is used to return projected space consumption
on any number of Hyper-V Virtual Machines if they are migrated to use the new format, and the
cluster free space before and after the migration.
If no Hyper-V Virtual Machine ID or list of
ID is given, it will report the projected space consumption of migrating all Hyper-V Virtual
Machines that are currently using the old format.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHvmFormatClusterStorage -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will return projected space consumption on Hyper-V VMs within the given Hyper-V VMs ID list, and cluster free space before and after migration.

### EXAMPLE 2
```
Get-RubrikHvmFormatClusterStorage
```

This will return projected space consumption of migrating all old-format Hyper-V VMs on the Rubrik cluster, and cluster free space before and after migration.

### EXAMPLE 3
```
Get-RubrikHvmFormatClusterStorage -Hostname 'Server1'
```

This will return projected space consumption of migrating all old-format Hyper-V VMs from host "Server1", and cluster free space before and after migration.

### EXAMPLE 4
```
Get-RubrikHvmFormatClusterStorage -Hostname 'Server1' -SLA Gold
```

This will return projected space consumption of migrating all old-format Hyper-V VMs of "Server1" that are protected by the Gold SLA Domain, and cluster free space before and after migration.

### EXAMPLE 5
```
Get-RubrikHvmFormatClusterStorage -Relic
```

This will return projected space consumption of migrating all old-format, removed Hyper-V VMs that were formerly protected by Rubrik, and cluster free space before and after migration.

### EXAMPLE 6
```
Get-RubrikHvmFormatClusterStorage -SetToUpgrade
```

This will return projected space consumption of migrating all old-format, removed Hyper-V VMs that have been set for a force full upgrade by specifying the forcefullspec.

### EXAMPLE 7
```
Get-RubrikHvmFormatClusterStorage -Id HypervVirtualMachine:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
```

This will return projected space consumption for the specified HypervVirtualMachine ID, and 0 if this HypervVirtualMachine uses fast VHDX format (no need for migration).

## PARAMETERS

### -name
Name of the HyperV Virtual Machine

```yaml
Type: String
Parameter Sets: (All)
Aliases: HypervVM

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -VMList
List of HyperV VM IDs

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
Prefix of HyperV VM names

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
Filter results to include only relic (removed) HyperV VMs

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
SLA Domain policy assigned to the HyperV VM

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
HyperV VM id

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

### -SetToUpgrade
Filter the report based on whether a Hyper-V Virtual Machine is set to take a full snapshot on the next backup.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ForceFullSpec

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayReport
Add the Hyper-V Virtual Machines Summary Report for VMs which haven't used the Fast VHDX builder.

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
Written by Abhinav Prakash for community usage
github: ab-prakash

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatclusterstorage](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatclusterstorage)

