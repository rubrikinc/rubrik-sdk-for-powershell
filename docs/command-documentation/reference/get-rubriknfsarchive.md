---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknfsarchive
schema: 2.0.0
---

# Get-RubrikNfsArchive

## SYNOPSIS
Connects to Rubrik and retrieves a list of NFS archive targets

## SYNTAX

### ID
```
Get-RubrikNfsArchive [-Id] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

### Query
```
Get-RubrikNfsArchive [[-Name] <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikNfsArchive cmdlet is used to pull a list of configured NFS archive targets from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNfsArchive
```

This will return all the NFS archive targets configured on the Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikNfsArchive -id '1111-2222-3333'
```

This will return the archive target with an id of '1111-2222-3333' on the Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikNfsArchive -Name 'NFS01'
```

This will return the archive target with a name of 'NFS01' on the Rubrik cluster.

## PARAMETERS

### -Id
NFS Archive ID

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
NFS Archive Name

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: 1
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknfsarchive](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknfsarchive)

