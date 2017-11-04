---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikReport

## SYNOPSIS
Retrieves details on one or more reports created in Rubrik Envision

## SYNTAX

```
Get-RubrikReport [[-Name] <String>] [[-Type] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>]
```

## DESCRIPTION
The Get-RubrikReport cmdlet is used to pull information on any number of Rubrik Envision reports

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikReport
```

This will return details on all reports

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikReport -Name 'SLA' -Type Custom
```

This will return details on all custom reports that contain the string "SLA"

### -------------------------- EXAMPLE 3 --------------------------
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

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

