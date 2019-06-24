---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/rubrik-sdk-for-powershell
schema: 2.0.0
---

# Update-RubrikHost

## SYNOPSIS
Refresh the properties shown for the specified host

## SYNTAX

```
Update-RubrikHost [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
Refresh the properties of a host object when changes on the host are not seen in the Rubrik web UI.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHost -Name "am1-sql16fc-1" | Update-RubrikHost
```

Get the details of Rubrikhost am1-sql16fc-1 and refresh the information of this host on the Rubrik Cluster and returns the information of the host

### EXAMPLE 2
```
Update-RubrikHost -id Host:::ccc9c8f4-6f16-4216-ba46-e9925c67d3b2
```

Refresh the information of this host by specifying the id on the Rubrik Cluster and returns the information of the host

## PARAMETERS

### -id
ID assigned to a host object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
Position: 2
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
Position: 3
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Lumnah
Twitter: @lumnah
GitHub: clumnah

## RELATED LINKS

[https://github.com/rubrikinc/rubrik-sdk-for-powershell](https://github.com/rubrikinc/rubrik-sdk-for-powershell)

