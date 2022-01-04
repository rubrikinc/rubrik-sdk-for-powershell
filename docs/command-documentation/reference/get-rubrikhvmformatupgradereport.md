---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatupgradereport
schema: 2.0.0
---

# Get-RubrikHvmFormatUpgradeReport

## SYNOPSIS
Returns projected space consumption of Hyper-V Virtual Machine format upgrade

## SYNTAX

```
Get-RubrikHvmFormatUpgradeReport [[-name] <String>] [-VMList <String[]>] [-NamePrefix <String>]
 [-hostname <String>] [-HostnamePrefix <String>] [-Relic] [-SLA <String>] [-PrimaryClusterID <String>]
 [-id <String>] [-SLAID <String>] [-SetToUpgrade] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHvmFormatUpgradeReport cmdlet is used to return the projected space consumption on any number of Hyper-V Virtual Machines if they are migrated to use the new format.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHvmFormatUpgradeReport -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will return projected space consumption on Hyper-V Virtual Machines within the given Hyper-V Virtual Machine ID list.

### EXAMPLE 2
```
Get-RubrikHvmFormatUpgradeReport
```

This will return projected space consumption on all Hyper-V Virtual Machines on the Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikHvmFormatUpgradeReport -Hostname 'Server1'
```

This will return projected space consumption on all Hyper-V Virtual Machines from host "Server1".

### EXAMPLE 4
```
Get-RubrikHvmFormatUpgradeReport -Hostname 'Server1' -SLA Gold
```

This will return projected space consumption on all Hyper-V Virtual Machines of "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 5
```
Get-RubrikHvmFormatUpgradeReport -Relic
```

This will return projected space consumption on all removed Hyper-V Virtual Machines that were formerly protected by Rubrik.

### EXAMPLE 6
```
Get-RubrikHvmFormatUpgradeReport -Id HypervVirtualMachine:::205b0b65-b90c-48c5-9cab-66b95ed18c0f
```

This will return projected space consumption for the specified HypervVirtualMachine ID

## PARAMETERS

### -name
Name of the Hyper-V Virtual Machine

```yaml
Type: String
Parameter Sets: (All)
Aliases: HypervVirtualMachine

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -VMList
List of Hyper-V Virtual Machine IDs

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
Prefix of Hyper-V Virtual Machine names

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
Filter results to include only relic (removed) Hyper-V Virtual Machines

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
SLA Domain policy assigned to the Hyper-V Virtual Machine

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
Hyper-V Virtual Machine id

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
Written by Abhinav Prakash for community usage
github: ab-prakash

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatupgradereport](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatupgradereport)

