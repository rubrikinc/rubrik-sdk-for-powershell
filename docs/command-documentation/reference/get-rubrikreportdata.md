---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreportdata
schema: 2.0.0
---

# Get-RubrikReportData

## SYNOPSIS
Retrieve table data for a specific Envision report

## SYNTAX

```
Get-RubrikReportData [-id] <String> [[-Name] <String>] [[-TaskType] <String>] [[-TaskStatus] <String>]
 [[-ObjectType] <String>] [[-ComplianceStatus] <String>] [[-limit] <Int32>] [[-cursor] <String>]
 [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikReportData cmdlet is used to pull table data from a specific Envision report

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData
```

This will return table data from the "SLA Compliance Summary" report

### EXAMPLE 2
```
Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance'
```

This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance"

### EXAMPLE 3
```
Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance' -Limit 10
```

This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance", only returns the first 10 results.

### EXAMPLE 4
```
Get-RubrikReport -Name 'Object Protection Summary' | Get-RubrikReportData -Limit -1
```

This will return all of the table data from the "Object Protection Summary" report.
Note: Using '-Limit -1' may affect performance for reports containing large amounts of data.

### EXAMPLE 5
```
(Get-RubrikReport -Name "System Capacity" | Get-RubrikReportData).DatagridObject | Format-Table
```

This will return a human readable table view of the items within the System Capacity report.

## PARAMETERS

### -id
The ID of the report

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
Search table data by object name

```yaml
Type: String
Parameter Sets: (All)
Aliases: search_value

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskType
Filter table data on task type

```yaml
Type: String
Parameter Sets: (All)
Aliases: task_type

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskStatus
Filter table data on task status

```yaml
Type: String
Parameter Sets: (All)
Aliases: task_status

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectType
Filter table data on object type

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_type

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComplianceStatus
Filter table data on compliance status

```yaml
Type: String
Parameter Sets: (All)
Aliases: compliance_status

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -limit
limit the number of rows returned, defaults to maximum pageSize of 9999.
Use a value of '-1' to remove limit restrictions

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -cursor
cursor start (if necessary)

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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreportdata](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreportdata)

