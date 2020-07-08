---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikarchive
schema: 2.0.0
---

# Get-RubrikArchive

## SYNOPSIS
Connects to Rubrik and retrieves a list of archive targets

## SYNTAX

### Query (Default)
```
Get-RubrikArchive [[-Name] <String>] [-ArchiveType <String>] [-DetailedObject] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikArchive [-Id] <String> [-DetailedObject] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikArchive cmdlet is used to pull a list of configured archive targets from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikArchive
```

This will return all the archive targets configured on the Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikArchive -name 'archive01'
```

This will return the archive targets configured on the Rubrik cluster with the name of 'archive01'.

## PARAMETERS

### -Id
Archive Location ID

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
Archive Location Name

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

### -ArchiveType
Filter by Archive location type (Currently S3 and Azure only)

```yaml
Type: String
Parameter Sets: Query
Aliases: location_type

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed archive object, the default behavior of the API is to only retrieve a subset of the archive object.
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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikarchive](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikarchive)

