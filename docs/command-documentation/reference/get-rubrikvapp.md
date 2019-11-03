---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikVApp

## SYNOPSIS
Connects to Rubrik and retrieves the current Rubrik vCD vApp settings

## SYNTAX

### Query (Default)
```
Get-RubrikVApp [[-Name] <String>] [-Relic] [-DetailedObject] [-SLA <String>] [-SLAAssignment <String>]
 [-PrimaryClusterID <String>] [-SLAID <String>] [-SourceObjectId <String>] [-SourceObjectName <String>]
 [-vcdClusterId <String>] [-vcdClusterName <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikVApp [-id] <String> [-SourceObjectId <String>] [-SourceObjectName <String>] [-vcdClusterId <String>]
 [-vcdClusterName <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVApp cmdlet retrieves all the vCD vApp settings actively running on the system.
This requires authentication with your Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVApp
```

This returns details on all vCD vApps that are currently or formerly protected by Rubrik.

### EXAMPLE 2
```
Get-RubrikVApp -Name 'vApp01'
```

This returns details on all vCD vApps named "vApp01".

### EXAMPLE 3
```
Get-RubrikVApp -Name 'Server1' -SLA 'Gold'
```

This returns details on all vCD vApps named "Server1" that are protected by the Gold SLA Domain.

### EXAMPLE 4
```
Get-RubrikVApp -Relic
```

This returns all removed vCD vApps that were formerly protected by Rubrik.

### EXAMPLE 5
```
Get-RubrikVApp -Relic:false
```

This returns all vCD vApps that are currently protected by Rubrik.

### EXAMPLE 6
```
Get-RubrikVApp -SourceObjectId 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567'
```

This returns details on all vCD vApps with the Source Object ID  "VcdVapp:::01234567-8910-1abc-d435-0abc1234d567"

### EXAMPLE 7
```
Get-RubrikVApp -vcdClusterId 'Vcd:::01234567-8910-1abc-d435-0abc1234d567'
```

This returns details on all vCD vApps on the vCD Cluster with id "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

## PARAMETERS

### -Name
Name of the vCD vApp

```yaml
Type: String
Parameter Sets: Query
Aliases: VM

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -id
vCD vApp id

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

### -Relic
Filter results to include only relic (removed) vCD vApps

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

### -DetailedObject
DetailedObject will retrieved the detailed vApp object, the default behavior of the API is to only retrieve a subset of the full vApp object unless we query directly by ID.
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

### -SLA
SLA Domain policy assigned to the vCD vApp

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
Aliases: sla_assignment

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
Use **local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

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

### -SourceObjectId
ID of Source Object in terms of vCD Hierarchy

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

### -SourceObjectName
Name of Source Object in terms of vCD Hierarchy

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

### -vcdClusterId
ID of vCD Cluster

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

### -vcdClusterName
Name of vCD Cluster

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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

