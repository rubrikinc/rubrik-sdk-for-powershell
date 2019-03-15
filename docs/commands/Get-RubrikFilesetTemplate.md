---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFilesetTemplate.html
schema: 2.0.0
---

# Get-RubrikFilesetTemplate

## SYNOPSIS
Retrieves details on one or more fileset templates known to a Rubrik cluster

## SYNTAX

```
Get-RubrikFilesetTemplate [[-Name] <String>] [[-OperatingSystemType] <String>] [[-shareType] <String>]
 [[-PrimaryClusterID] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikFilesetTemplate cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of fileset templates

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikFilesetTemplate -Name 'Template1'
```

This will return details on all fileset templates named "Template1"

### EXAMPLE 2
```
Get-RubrikFilesetTemplate -OperatingSystemType 'Linux'
```

This will return details on all fileset templates that can be used against a Linux operating system type

### EXAMPLE 3
```
Get-RubrikFilesetTemplate -id '11111111-2222-3333-4444-555555555555'
```

This will return details on the fileset template matching id "11111111-2222-3333-4444-555555555555"

## PARAMETERS

### -Name
Retrieve fileset templates with a name matching the provided name.
The search is performed as a case-insensitive infix search.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FilesetTemplate

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperatingSystemType
Filter the summary information based on the operating system type of the fileset.
Accepted values: 'Windows', 'Linux'

```yaml
Type: String
Parameter Sets: (All)
Aliases: operating_system_type

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -shareType
Filter the summary information based on the share type of the fileset.
Accepted values: 'NFS', 'SMB'

```yaml
Type: String
Parameter Sets: (All)
Aliases: share_type

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

### -id
The ID of the fileset template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFilesetTemplate.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFilesetTemplate.html)

