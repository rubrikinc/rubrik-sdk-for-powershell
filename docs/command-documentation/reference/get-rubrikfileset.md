---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFileset.html
schema: 2.0.0
---

# Get-RubrikFileset

## SYNOPSIS

Retrieves details on one or more filesets known to a Rubrik cluster

## SYNTAX

### Query \(Default\)

```text
Get-RubrikFileset [[-Name] <String>] [-HostName <String>] [-id <String>] [-Relic] [-DetailedObject]
 [-SLA <String>] [-TemplateID <String>] [-PrimaryClusterID <String>] [-ShareID <String>] [-SLAID <String>]
 [-Server <String>] [-api <String>] [<CommonParameters>]
```

### Filter

```text
Get-RubrikFileset [-NameFilter <String>] [-HostNameFilter <String>] [-id <String>] [-Relic] [-DetailedObject]
 [-SLA <String>] [-TemplateID <String>] [-PrimaryClusterID <String>] [-ShareID <String>] [-SLAID <String>]
 [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID

```text
Get-RubrikFileset [-id <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikFileset cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of filesets A number of parameters exist to help narrow down the specific fileset desired Note that a fileset name is not required; you can use params \(such as HostName and SLA\) to do lookup matching filesets

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikFileset -Name 'C_Drive'
```

This will return details on the fileset named "C\_Drive" assigned to any hosts

### EXAMPLE 2

```text
Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
```

This will return details on the fileset named "C\_Drive" assigned to only the "Server1" host

### EXAMPLE 3

```text
Get-RubrikFileset -Name 'C_Drive' -SLA Gold
```

This will return details on the fileset named "C\_Drive" assigned to any hosts with an SLA Domain matching "Gold"

### EXAMPLE 4

```text
Get-RubrikFileset -NameFilter '_Drive' -SLA Gold
```

This will return details on the filesets that contain the string "\_Drive" in its name and are assigned to any hosts with an SLA Domain matching "Gold"

### EXAMPLE 5

```text
Get-RubrikFileset -HostName 'mssqlserver01' -SLA Gold
```

This will return details on the filesets for the hostname "mssqlserver01" and are assigned to any hosts with an SLA Domain matching "Gold"

### EXAMPLE 6

```text
Get-RubrikFileset -HostNameFilter 'mssql' -SLA Gold
```

This will return details on the filesets that contain the string "mssql" in its parent's hostname and are assigned to any hosts with an SLA Domain matching "Gold"

### EXAMPLE 7

```text
Get-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
```

This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

### EXAMPLE 8

```text
Get-RubrikFileset -Relic
```

This will return all removed filesets that were formerly protected by Rubrik.

### EXAMPLE 9

```text
Get-RubrikFileset -DetailedObject
```

This will return the fileset object with all properties, including additional details such as snapshots taken of the Fileset object. Using this switch parameter negatively affects performance

## PARAMETERS

### -Name

Name of the fileset

```yaml
Type: String
Parameter Sets: Query
Aliases: Fileset

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NameFilter

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostName

Exact name of the host using a fileset Partial match of hostname, using an 'in fix' search.

```yaml
Type: String
Parameter Sets: Query
Aliases: host_name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostNameFilter

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id

Rubrik's fileset id

```yaml
Type: String
Parameter Sets: Query, Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Relic

Filter results to include only relic \(removed\) filesets

```yaml
Type: SwitchParameter
Parameter Sets: Query, Filter
Aliases: is_relic

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject

DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full Fileset object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

```yaml
Type: SwitchParameter
Parameter Sets: Query, Filter
Aliases:

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
Parameter Sets: Query, Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateID

Filter the summary information based on the ID of a fileset template.

```yaml
Type: String
Parameter Sets: Query, Filter
Aliases: template_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryClusterID

Filter the summary information based on the primarycluster\_id of the primary Rubrik cluster. Use **\_local** as the primary\_cluster\_id of the Rubrik cluster that is hosting the current REST API session.

```yaml
Type: String
Parameter Sets: Query, Filter
Aliases: primary_cluster_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShareID

Rubrik's Share id

```yaml
Type: String
Parameter Sets: Query, Filter
Aliases: share_id

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
Parameter Sets: Query, Filter
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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Chris Wahl for community usage Twitter: @ChrisWahl GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFileset.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFileset.html)

