---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikEvent
schema: 2.0.0
---

# Get-RubrikEvent

## SYNOPSIS

Retrieve information for events that match the value specified in any of the following categories: type, status, or ID, and limit events by date.

## SYNTAX

```text
Get-RubrikEvent [[-Limit] <Int32>] [[-AfterId] <String>] [[-EventSeriesId] <String>] [[-Status] <String>]
 [[-EventType] <String>] [[-id] <Array>] [[-ObjectName] <String>] [[-BeforeDate] <DateTime>]
 [[-AfterDate] <DateTime>] [[-ObjectType] <String>] [-ShowOnlyLatest] [-FilterOnlyOnLatest]
 [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikEvent cmdlet is used to pull a event data set from a Rubrik cluster. There are a vast number of arguments that can be supplied to narrow down the event query.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikEvent -ObjectName "vm-foo" -EventType Backup
```

This will query for any 'Backup' events on the Rubrik VM object named 'vm-foo'

### EXAMPLE 2

```text
Get-RubrikVM -Name jbrasser-win | Get-RubrikEvent -Limit 10
```

Queries the Rubrik Cluster for any vms named jbrasser-win and return the last ten events for each VM found

### EXAMPLE 3

```text
Get-RubrikEvent -EventType Archive -Limit 100
```

This qill query the latest 100 Archive events on the currently logged in Rubrik cluster

### EXAMPLE 4

```text
Get-RubrikHost -Name SQLFoo.demo.com | Get-RubrikEvent -EventType Archive
```

This will feed any Archive events against the Rubrik Host object 'SQLFoo.demo.com' via a piped query.

## PARAMETERS

### -Limit

Maximum number of events retrieved, default is to return 50 objects

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 50
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterId

Earliest event retrieved

```yaml
Type: String
Parameter Sets: (All)
Aliases: after_id

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventSeriesId

Filter by Event Series ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: event_series_id

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status

Filter by Status. Enter any of the following values: 'Failure', 'Warning', 'Running', 'Success', 'Canceled', 'Cancelingâ€™.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventType

Filter by Event Type.

```yaml
Type: String
Parameter Sets: (All)
Aliases: event_type

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id

Filter by a comma separated list of object IDs.

```yaml
Type: Array
Parameter Sets: (All)
Aliases: object_ids

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ObjectName

Filter all the events according to the provided name using infix search for resources and exact search for usernames.

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_name

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BeforeDate

Filter all the events before a date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: before_date

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterDate

Filter all the events after a date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: after_date

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectType

Filter all the events by object type. Enter any of the following values: 'VmwareVm', 'Mssql', 'LinuxFileset', 'WindowsFileset', 'WindowsHost', 'LinuxHost', 'StorageArrayVolumeGroup', 'VolumeGroup', 'NutanixVm', 'Oracle', 'AwsAccount', and 'Ec2Instance'. WindowsHost maps to both WindowsFileset and VolumeGroup, while LinuxHost maps to LinuxFileset and StorageArrayVolumeGroup.

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_type

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowOnlyLatest

A switch value that determines whether to show only on the most recent event in the series. When 'true' only the most recent event in the series are shown. When 'false' all events in the series are shown. The default value is 'true'.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: show_only_latest

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOnlyOnLatest

A Switch value that determines whether to filter only on the most recent event in the series. When 'true' only the most recent event in the series are filtered. When 'false' all events in the series are filtered. The default value is 'true'.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: filter_only_on_latest

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

Written by J.R. Phillips for community usage GitHub: JayAreP

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikEvent](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikEvent)

