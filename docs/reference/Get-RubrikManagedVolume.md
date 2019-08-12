---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/
schema: 2.0.0
---

# Get-RubrikManagedVolume

## SYNOPSIS
Gets data on a Rubrik managed volume

## SYNTAX

### Name (Default)
```
Get-RubrikManagedVolume [[-Name] <String>] [-SLA <String>] [-SLAID <String>] [-Relic]
 [-PrimaryClusterID <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikManagedVolume [-id] <String> [-SLA <String>] [-SLAID <String>] [-Relic] [-PrimaryClusterID <String>]
 [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikManagedVolume cmdlet is used to retrive information 
on one or more managed volumes that are being protected 
with Rubrik.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikManagedVolume
```

Retrieves all Rubrik Managed Volumes, active and relics

### EXAMPLE 2
```
Get-RubrikManagedVolume -Relic
```

Retrieves all Rubrik Managed Volumes that are relics

### EXAMPLE 3
```
Get-RubrikManagedVolume -Relic:$false
```

Retrieves all Rubrik Managed Volumes that are not relics

### EXAMPLE 4
```
Get-RubrikManagedVolume -name sqltest
```

Get a managed volume named sqltest

### EXAMPLE 5
```
Get-RubrikManagedVolume -SLA 'Foo'
```

Get all managed volumes protected by the 'Foo' SLA domain.

### EXAMPLE 6
```
Get-RubrikManagedVolume -Name 'Bar'
```

Get the managed volume named 'Bar'.

## PARAMETERS

### -id
id of managed volume

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
Name of managed volume

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SLA
SLA name that the managed volume is protected under

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

### -SLAID
SLA id that the managed volume is protected under

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

### -Relic
Filter results to include only relic (removed) databases

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

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
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
Written by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

