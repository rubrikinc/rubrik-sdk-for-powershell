---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriklogshipping
schema: 2.0.0
---

# Get-RubrikLogShipping

## SYNOPSIS
Retrieves all log shipping configuration objects.
Results can be filtered and sorted.

## SYNTAX

```
Get-RubrikLogShipping [-id <String>] [-PrimaryDatabaseId <String>] [[-PrimaryDatabaseName] <String>]
 [-SecondaryDatabaseName <String>] [-location <String>] [-status <String>] [-limit <String>] [-offset <String>]
 [-sort_by <String>] [-sort_order <String>] [-DetailedObject] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves all log shipping configuration objects.
Results can be filtered and sorted.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikLogShipping
```

Get all log shipping configurations

### EXAMPLE 2
```
Get-RubrkLogShipping -PrimaryDatabase 'AdventureWorks2014'
```

Get all log shipping configurations for the 'AdventureWorks2014' database

### EXAMPLE 3
```
Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER
```

Get all log shipping configurations for a given location (log shipping secondary server)

### EXAMPLE 4
```
Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER -DetailedObject
```

Get all log shipping configurations for a given location (log shipping secondary server) and retrieves detailed information about these objects

## PARAMETERS

### -id
{{ Fill id Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PrimaryDatabaseId
{{ Fill PrimaryDatabaseId Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_database_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryDatabaseName
{{ Fill PrimaryDatabaseName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_database_name

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecondaryDatabaseName
{{ Fill SecondaryDatabaseName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: secondary_database_name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -location
Log Shipping Target Server

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

### -status
{{ Fill status Description }}

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

### -limit
{{ Fill limit Description }}

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

### -offset
{{ Fill offset Description }}

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

### -sort_by
{{ Fill sort_by Description }}

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

### -sort_order
{{ Fill sort_order Description }}

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

### -DetailedObject
DetailedObject will retrieved the detailed LogShipping object, the default behavior of the API is to only retrieve a subset of the full LogShipping object unless we query directly by ID.
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
Written by Chris Lumnah
Twitter: @lumnah
GitHub: clumnah
Any other links you'd like here

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriklogshipping](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriklogshipping)

