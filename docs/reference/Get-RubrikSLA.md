---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikSLA

## SYNOPSIS
Connects to Rubrik and retrieves details on SLA Domain(s)

## SYNTAX

```
Get-RubrikSLA [[-Name] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-Server] <String>]
 [[-api] <String>]
```

## DESCRIPTION
The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
Information on each domain will be reported to the console.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikSLA
```

Will return all known SLA Domains

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikSLA -Name 'Gold'
```

Will return details on the SLA Domain named Gold

## PARAMETERS

### -Name
Name of the SLA Domain

```yaml
Type: String
Parameter Sets: (All)
Aliases: SLA

Required: False
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
SLA Domain id

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
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
Position: 5
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

