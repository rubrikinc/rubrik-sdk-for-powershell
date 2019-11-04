---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSnapshot
schema: 2.0.0
---

# Get-RubrikSnapshot

## SYNOPSIS

Retrieves all of the snapshots \(backups\) for any given object

## SYNTAX

### Latest

```text
Get-RubrikSnapshot -id <String> [-CloudState <Int32>] [-OnDemandSnapshot] [-Latest] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

### Date

```text
Get-RubrikSnapshot -id <String> [-CloudState <Int32>] [-OnDemandSnapshot] -Date <DateTime> [-Range <Int32>]
 [-ExactMatch] [-Server <String>] [-api <String>] [<CommonParameters>]
```

### Query

```text
Get-RubrikSnapshot -id <String> [-CloudState <Int32>] [-OnDemandSnapshot] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots \(backups\) for any protected object The correct API call will be made based on the object id submitted Multiple objects can be piped into this function so long as they contain the id required for lookup

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
```

This will return all snapshot \(backup\) data for the virtual machine id of "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"

### EXAMPLE 2

```text
Get-RubrikSnapshot -id 'Fileset:::01234567-8910-1abc-d435-0abc1234d567'
```

This will return all snapshot \(backup\) data for the fileset with id of "Fileset:::01234567-8910-1abc-d435-0abc1234d567"

### EXAMPLE 3

```text
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/21/2017'
```

This will return the closest matching snapshot, within 1 day, to March 21st, 2017 for any virtual machine named "Server1"

### EXAMPLE 4

```text
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/21/2017' -Range 3
```

This will return the closest matching snapshot, within 3 days, to March 21st, 2017 for any virtual machine named "Server1"

### EXAMPLE 5

```text
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/21/2017' -Range 3 -ExactMatch
```

This will return the closest matching snapshot, within 3 days, to March 21st, 2017 for any virtual machine named "Server1". -ExactMatch specifies that no results are returned if a match is not found, otherwise all snapshots are returned.

### EXAMPLE 6

```text
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date (Get-Date)
```

This will return the closest matching snapshot to the current date and time for any virtual machine named "Server1"

### EXAMPLE 7

```text
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Latest
```

This will return the latest snapshot for the virtual machine named "Server1"

### EXAMPLE 8

```text
Get-RubrikDatabase 'DB1' | Get-RubrikSnapshot -OnDemandSnapshot
```

This will return the details on any on-demand \(user initiated\) snapshot to for any database named "DB1"

## PARAMETERS

### -id

Rubrik id of the protected object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CloudState

Filter results based on where in the cloud the snapshot lives

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnDemandSnapshot

Filter results to show only snapshots that were created on demand

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

### -Date

Date of the snapshot

```yaml
Type: DateTime
Parameter Sets: Date
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Range

Range of how many days away from $Date to search for the closest matching snapshot. Defaults to one day.

```yaml
Type: Int32
Parameter Sets: Date
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExactMatch

Return no results if a matching date isn't found. Otherwise, all snapshots are returned if no match is made.

```yaml
Type: SwitchParameter
Parameter Sets: Date
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest

Return the latest snapshot

```yaml
Type: SwitchParameter
Parameter Sets: Latest
Aliases:

Required: True
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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Chris Wahl for community usage Twitter: @ChrisWahl GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSnapshot](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSnapshot)

