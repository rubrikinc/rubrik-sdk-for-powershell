---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikReport.html
schema: 2.0.0
---

# New-RubrikReport

## SYNOPSIS
Create a new report by specifying one of the report templates

## SYNTAX

```
New-RubrikReport [-Name] <String> [-ReportTemplate] <String> [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikReport cmdlet is used to create a new Envision report by specifying one of the canned report templates

## EXAMPLES

### EXAMPLE 1
```
New-RubrikReport -Name 'Report1' -ReportTemplate 'ProtectionTasksDetails'
```

This will create a new report named "Report1" by using the "ProtectionTasksDetails" report template

## PARAMETERS

### -Name
The name of the report

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportTemplate
The template this report is based on

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikReport.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikReport.html)

