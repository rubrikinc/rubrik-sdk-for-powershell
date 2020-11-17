---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikreport
schema: 2.0.0
---

# Set-RubrikReport

## SYNOPSIS
Change report settings by taking an existing report and making the desired changes

## SYNTAX

```
Set-RubrikReport [-id] <String> [-Name] <String> [-chart0] <Object> [-chart1] <Object> [-filters] <Object>
 [-table] <Object> [[-NewName] <String>] [[-NewTableColumns] <String[]>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikReport cmdlet is used to change settings on an existing report by specifying one or more parameters to make these changes.
Currently it is supported to change the new and the colums displayed in the table.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikReport -Name 'Boring Report' -DetailedObject | Set-RubrikReport -NewName 'Quokka Report'
```

This will rename the report named 'Boring Report' to 'Quokka Report'

### EXAMPLE 2
```
Get-RubrikReport -Name 'Quokka Report' -DetailedObject | Set-RubrikReport -NewTableColumns TaskStatus, TaskType, ObjectName, ObjectType, Location, SlaDomain, StartTime, EndTime, Duration, DataTransferred, DataStored, DedupRatioForJob
```

This will change the table colums in 'Quokka Report' to the specified values in the -NewTableColums parameter

## PARAMETERS

### -id
The ID of the report.

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

### -Name
The new name of the report

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -chart0
{{ Fill chart0 Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -chart1
{{ Fill chart1 Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -filters
{{ Fill filters Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -table
{{ Fill table Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewName
{{ Fill NewName Description }}

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

### -NewTableColumns
{{ Fill NewTableColumns Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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
Position: 9
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
Position: 10
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikreport](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikreport)

