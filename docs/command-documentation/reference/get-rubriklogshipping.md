---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLogShipping
schema: 2.0.0
---

# Get-RubrikLogShipping

## SYNOPSIS

Retrieves all log shipping configuration objects. Results can be filtered and sorted.

## SYNTAX

```text
Get-RubrikLogShipping [[-id] <String>] [[-PrimaryDatabaseId] <String>] [[-PrimaryDatabaseName] <String>]
 [[-SecondaryDatabaseName] <String>] [[-location] <String>] [[-status] <String>] [[-limit] <String>]
 [[-offset] <String>] [[-sort_by] <String>] [[-sort_order] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Retrieves all log shipping configuration objects. Results can be filtered and sorted.

## EXAMPLES

### EXAMPLE 1

```text
Get all log shipping configurations
```

Get-RubrikLogShipping

### EXAMPLE 2

```text
Get all log shipping configurations for a given database
```

Get-RubrkLogShipping -PrimaryDatabase 'AdventureWorks2014'

### EXAMPLE 3

```text
Get all log shipping configurations for a given location (log shipping secondary server)
```

Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER

## PARAMETERS

### -id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PrimaryDatabaseId

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_database_id

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryDatabaseName

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_database_name

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecondaryDatabaseName

```yaml
Type: String
Parameter Sets: (All)
Aliases: secondary_database_name

Required: False
Position: 4
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -status

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -offset

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort\_by

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sort\_order

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
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
Position: 11
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
Position: 12
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Chris Lumnah Twitter: @lumnah GitHub: clumnah Any other links you'd like here

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLogShipping](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLogShipping)

