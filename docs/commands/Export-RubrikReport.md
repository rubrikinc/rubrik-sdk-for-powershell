---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikReport.html
schema: 2.0.0
---

# Export-RubrikReport

## SYNOPSIS
Retrieves link to a CSV file for a Rubrik Envision report

## SYNTAX

```
Export-RubrikReport [-id] <String> [[-TimezoneOffset] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Export-RubrikReport cmdlet is used to pull the link to a CSV file for a Rubrik Envision report

## EXAMPLES

### EXAMPLE 1
```
Export-RubrikReport -id '11111111-2222-3333-4444-555555555555' -timezone_offset 120
```

This will return the link to a CSV file for report id "11111111-2222-3333-4444-555555555555"

### EXAMPLE 2
```
Get-RubrikReport -Name 'Protection Tasks Details' | Export-RubrikReport
```

This will return the link to a CSV file for report named "Protection Tasks Details"

## PARAMETERS

### -id
ID of the report.

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

### -TimezoneOffset
Timezone offset from UTC in minutes.

```yaml
Type: String
Parameter Sets: (All)
Aliases: timezone_offset

Required: False
Position: 2
Default value: 0
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
Position: 3
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
Position: 4
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Bas Vinken for community usage
Twitter: @bvinken
GitHub: basvinken

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikReport.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikReport.html)

