---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikscvmm
schema: 2.0.0
---

# Get-RubrikScvmm

## SYNOPSIS
Connects to Rubrik and retrieves the current Rubrik SCVMM server settings

## SYNTAX

### Query (Default)
```
Get-RubrikScvmm [[-Name] <String>] [-PrimaryClusterID <String>] [-DetailedObject] [-SLAAssignment <String>]
 [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikScvmm [-Id] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikScvmm cmdlet will retrieve SCVMM servers and settings currently configured on the cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikScvmm
```

This will return all of the SCVMM servers and associated settings on the currently connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikScvmm -Name 'scvmm.domain.local'
```

This will return the SCVMM server settings for the SCVMM server named 'scvmm.domain.local'

### EXAMPLE 3
```
Get-RubrikScvmm -PrimaryClusterId '1111-2222-3333'
```

This will return the SCVMM server settings any server directly attached to the cluster with an id of '1111-2222-3333'

### EXAMPLE 4
```
Get-RubrikScvmm -Id '1111-2222-3333'
```

This will return the SCVMM server settings with an id of '1111-2222-3333'

### EXAMPLE 5
```
Get-RubrikScvmm -SLA 'Gold'
```

This will return the SCVMM server settings any server assigned to the Gold SLA Domain on the cluster

## PARAMETERS

### -Id
SCVMM Server ID

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
SCVMM Server Name

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

### -DetailedObject
DetailedObject will retrieved the detailed SCVMM object, the default behavior of the API is to only retrieve a subset of the full SCVMM object unless we query directly by ID.
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

### -SLAAssignment
Filter by SLA Domain assignment type

```yaml
Type: String
Parameter Sets: Query
Aliases: sla_assignment

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
SLA Domain policy assigned to the SCVMM Server

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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikscvmm](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikscvmm)

