---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervvm
schema: 2.0.0
---

# Get-RubrikHyperVVM

## SYNOPSIS
Retrieves details on one or more Hyper-V virtual machines known to a Rubrik cluster

## SYNTAX

### Query (Default)
```
Get-RubrikHyperVVM [[-Name] <String>] [-Relic] [-SLA <String>] [-SLAAssignment <String>]
 [-PrimaryClusterID <String>] [-SLAID <String>] [-DetailedObject] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### ID
```
Get-RubrikHyperVVM [-id] <String> [-DetailedObject] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHyperVVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Hyper-V virtual machines

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHyperVVM -Name 'Server1'
```

This will return details on all Hyper-V virtual machines named "Server1".

### EXAMPLE 2
```
Get-RubrikHyperVVM -Name 'Server1' -SLA Gold
```

This will return details on all Hyper-V virtual machines named "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 3
```
Get-RubrikHyperVVM -Name 'Server1' -DetailedObject
```

This will return all Hyper-V virtual machines named "Server1" and returns the Detailed Objects of these VMs

### EXAMPLE 4
```
Get-RubrikHyperVVM -Relic
```

This will return all removed Hyper-V virtual machines that were formerly protected by Rubrik.

## PARAMETERS

### -Name
Name of the Hyper-V virtual machine

```yaml
Type: String
Parameter Sets: Query
Aliases: VM

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Relic
Filter results to include only relic (removed) virtual machines

```yaml
Type: SwitchParameter
Parameter Sets: Query
Aliases: is_relic

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
SLA Domain policy assigned to the virtual machine

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAAssignment
Filter by SLA Domain assignment type

```yaml
Type: String
Parameter Sets: Query
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
Parameter Sets: Query
Aliases: primary_cluster_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Virtual machine id

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

### -SLAID
SLA id value

```yaml
Type: String
Parameter Sets: Query
Aliases: effective_sla_domain_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed Hyper-V VM object, the default behavior of the API is to only retrieve a subset of the full Hyper-V VM object unless we query directly by ID.
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervvm](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervvm)

