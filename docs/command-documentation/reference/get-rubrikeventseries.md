---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikeventseries
schema: 2.0.0
---

# Get-RubrikEventSeries

## SYNOPSIS
Retrieve information for events grouped by event series

## SYNTAX

```
Get-RubrikEventSeries [[-Id] <String>] [[-Status] <String>] [[-EventType] <String>] [[-objectIds] <Array>]
 [[-ObjectName] <String>] [[-ObjectType] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikEventSeries cmdlet is used to pull a event data from a event series within a Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikEventSeries -id '1111-2222-3333'
```

This will return details for the specified event series, along with its' associated events in the Rubrik Cluster

## PARAMETERS

### -Id
Filter by Event Series ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Filter by Status.
Enter any of the following values: 'Failure', 'Warning', 'Running', 'Success', 'Canceled', 'Canceling'.
Note: Deprecated in 5.2

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventType
Filter by Event Type.
Note: Deprecated in 5.2

```yaml
Type: String
Parameter Sets: (All)
Aliases: event_type

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -objectIds
Filter by a comma separated list of object IDs.
Note: Deprecated in 5.2

```yaml
Type: Array
Parameter Sets: (All)
Aliases: object_ids

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ObjectName
Filter all the events according to the provided name using infix search for resources and exact search for usernames.
Note: Deprecated in 5.2

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_name

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectType
Filter all the events by object type.
Enter any of the following values: 'VmwareVm', 'Mssql', 'LinuxFileset', 'WindowsFileset', 'WindowsHost', 'LinuxHost', 'StorageArrayVolumeGroup', 'VolumeGroup', 'NutanixVm', 'Oracle', 'AwsAccount', and 'Ec2Instance'.
WindowsHost maps to both WindowsFileset and VolumeGroup, while LinuxHost maps to LinuxFileset and StorageArrayVolumeGroup.
Note: Deprecated in 5.2

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_type

Required: False
Position: 6
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
Position: 7
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
Position: 8
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikeventseries](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikeventseries)

