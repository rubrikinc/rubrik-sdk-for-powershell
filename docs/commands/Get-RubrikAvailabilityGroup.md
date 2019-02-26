---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/
schema: 2.0.0
---

# Get-RubrikAvailabilityGroup

## SYNOPSIS
Retrieves details on one or more Avaialbility Group known to a Rubrik cluster

## SYNTAX

```
Get-RubrikAvailabilityGroup [[-id] <String>] [[-GroupName] <String>] [[-SLA] <String>]
 [[-PrimaryClusterID] <String>] [[-SLAID] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikAvailabilityGroup cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Availability Groups.
To narrow down the results, use the group name or SLA limit your search to a smaller group of objects.
Alternatively, supply the Rubrik database ID to return only one specific database.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag'
```

This will return details on the Availability Group

## PARAMETERS

### -id
{{Fill id Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
Name of the availability group

```yaml
Type: String
Parameter Sets: (All)
Aliases: name

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
SLA Domain policy assigned to the database

```yaml
Type: String
Parameter Sets: (All)
Aliases: effectiveSlaDomainName

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_cluster_id

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID
{{Fill SLAID Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: effectiveSlaDomainId

Required: False
Position: 5
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
Position: 6
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
Position: 7
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Lumnah for community usage
Twitter: @lumnah
GitHub: clumnah

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

