---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/find-rubrikfile
schema: 2.0.0
---

# Find-RubrikFile

## SYNOPSIS
Searches snapshots for files within a Rubrik protected object.

## SYNTAX

### Query (Default)
```
Find-RubrikFile [-id] <String> [[-SearchString] <String>] [[-Limit] <String>] [[-Cursor] <String>] [-DetailedObject] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Find-RubrikFile cmdlet uses the internal search API to find files within snapshots of protected objects.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVM -Sla Gold | Find-RubrikFile -SearchString "pizza"
```

This example will search all VM snapshots in the Gold SLA for a filename containing "pizza".

### EXAMPLE 2
```
Get-RubrikFileset -HostName MyVM | Find-RubrikFile -SearchString "pancake"
```

This example will search filesets for the VM "MyVM" for a filename containing "pancake".

## PARAMETERS

### -Id
ID of the object to search

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SearchString
String to search for in filename

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Limit
Limit the number of search results (API defaults to 100)

```yaml
Type: String
Parameter Sets: Query
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
Written by Jake Robinson for community usage
Twitter: @jakerobinson
GitHub: jakerobinson

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/find-rubrikfile](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/find-rubrikfile)

