---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksla
schema: 2.0.0
---

# Get-RubrikSLA

## SYNOPSIS
Connects to Rubrik and retrieves details on SLA Domain(s)

## SYNTAX

### Query (Default)
```
Get-RubrikSLA [[-Name] <String>] [-PrimaryClusterID <String>] [-DetailedObject] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikSLA [-PrimaryClusterID <String>] [-id] <String> [-DetailedObject] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
Information on each domain will be reported to the console.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikSLA
```

Will return all known SLA Domains

### EXAMPLE 2
```
Get-RubrikSLA -Name 'Gold'
```

Will return details on the SLA Domain named Gold

### EXAMPLE 3
```
Get-RubrikSLA -Name 'Gold' -DetailedObject
```

Will return information the SLA Domain named Gold, including full details on this SLA

## PARAMETERS

### -Name
Name of the SLA Domain

```yaml
Type: String
Parameter Sets: Query
Aliases: SLA

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

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
SLA Domain id

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

### -DetailedObject
DetailedObject will retrieved the detailed SLA object, the default behavior of the API is to only retrieve a subset of the full SLA object unless we query directly by ID.
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksla](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksla)

