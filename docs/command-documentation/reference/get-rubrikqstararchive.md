---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikqstararchive
schema: 2.0.0
---

# Get-RubrikQstarArchive

## SYNOPSIS
Connects to Rubrik and retrieves a list of QStar archive targets

## SYNTAX

### Query (Default)
```
Get-RubrikQstarArchive [[-Name] <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikQstarArchive [-Id] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikQstarArchive cmdlet is used to pull a list of configured QStar archive targets from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikQstarArchive
```

This will return all the QStar archive targets configured on the Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikQstarArchive -id '1111-2222-3333'
```

This will return the archive target with an id of '1111-2222-3333' on the Rubrik cluster.

### EXAMPLE 3
```
Get-RubrikQstarArchive -Name 'QStar01'
```

This will return the archive target with a name of 'QStar01' on the Rubrik cluster.

## PARAMETERS

### -Id
QStar Archive ID

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
QStar Archive Name

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikqstararchive](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikqstararchive)

