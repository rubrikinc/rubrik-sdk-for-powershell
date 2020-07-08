---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixvm
schema: 2.0.0
---

# Get-RubrikNutanixVM

## SYNOPSIS
Retrieves details on one or more Nutanix (AHV) virtual machines known to a Rubrik cluster

## SYNTAX

### Query (Default)
```
Get-RubrikNutanixVM [[-Name] <String>] [-Relic] [-SLA <String>] [-SLAAssignment <String>]
 [-PrimaryClusterID <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikNutanixVM [-id] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikNutanixVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Nutanix (AHV) virtual machines

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNutanixVM -Name 'Server1'
```

This will return details on all Nutanix (AHV) virtual machines named "Server1".

### EXAMPLE 2
```
Get-RubrikNutanixVM -Name 'Server1' -SLA Gold
```

This will return details on all Nutanix (AHV) virtual machines named "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 3
```
Get-RubrikNutanixVM -Relic
```

This will return all removed Nutanix (AHV) virtual machines that were formerly protected by Rubrik.

## PARAMETERS

### -Name
Name of the Nutanix (AHV) virtual machine

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixvm](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixvm)

