---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikFileset

## SYNOPSIS
Retrieves details on one or more filesets known to a Rubrik cluster

## SYNTAX

```
Get-RubrikFileset [[-Name] <String>] [-Relic] [[-SLA] <String>] [[-HostName] <String>] [[-TemplateID] <String>]
 [[-PrimaryClusterID] <String>] [[-id] <String>] [[-SLAID] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikFileset cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of filesets
A number of parameters exist to help narrow down the specific fileset desired
Note that a fileset name is not required; you can use params (such as HostName and SLA) to do lookup matching filesets

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikFileset -Name 'C_Drive'
```

This will return details on the fileset named "C_Drive" assigned to any hosts

### EXAMPLE 2
```
Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
```

This will return details on the fileset named "C_Drive" assigned to only the "Server1" host

### EXAMPLE 3
```
Get-RubrikFileset -Name 'C_Drive' -SLA Gold
```

This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"

### EXAMPLE 4
```
Get-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
```

This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

### EXAMPLE 5
```
Get-RubrikFileset -Relic
```

This will return all removed filesets that were formerly protected by Rubrik.

## PARAMETERS

### -Name
Name of the fileset

```yaml
Type: String
Parameter Sets: (All)
Aliases: Fileset

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Relic
Filter results to include only relic (removed) filesets

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
SLA Domain policy assigned to the database

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostName
Name of the host using a fileset

```yaml
Type: String
Parameter Sets: (All)
Aliases: host_name

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateID
Filter the summary information based on the ID of a fileset template.

```yaml
Type: String
Parameter Sets: (All)
Aliases: template_id

Required: False
Position: 4
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Rubrik's fileset id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Position: 7
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
Position: 8
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
Position: 9
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

