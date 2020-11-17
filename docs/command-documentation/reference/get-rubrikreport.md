---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreport
schema: 2.0.0
---

# Get-RubrikReport

## SYNOPSIS
Retrieves details on one or more reports created in Rubrik Envision

## SYNTAX

```
Get-RubrikReport [[-Name] <String>] [[-Type] <String>] [[-id] <String>] [-DetailedObject] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikReport cmdlet is used to pull information on any number of Rubrik Envision reports

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikReport
```

This will return details on all reports

### EXAMPLE 2
```
Get-RubrikReport -DetailedObject
```

This will return full details on all reports

### EXAMPLE 3
```
Get-RubrikReport -Name 'SLA' -Type Custom
```

This will return details on all custom reports that contain the string "SLA"

### EXAMPLE 4
```
Get-RubrikReport -id '11111111-2222-3333-4444-555555555555'
```

This will return details on the report id "11111111-2222-3333-4444-555555555555"

## PARAMETERS

### -Name
Filter the returned reports based off their name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: search_text

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Filter the returned reports based off the reports type.
Options are Canned and Custom.

```yaml
Type: String
Parameter Sets: (All)
Aliases: report_type

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
The ID of the report.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed Rubrik Report object, the default behavior of the API is to only retrieve a subset of the full Rubrik Report object unless we query directly by ID.
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
Position: 4
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
Position: 5
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreport](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreport)

