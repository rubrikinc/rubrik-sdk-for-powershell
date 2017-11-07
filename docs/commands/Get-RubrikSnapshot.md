---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikSnapshot

## SYNOPSIS
Retrieves all of the snapshots (backups) for any given object

## SYNTAX

```
Get-RubrikSnapshot [-id] <String> [[-CloudState] <Int32>] [-OnDemandSnapshot] [[-Date] <DateTime>]
 [[-Server] <String>] [[-api] <String>]
```

## DESCRIPTION
The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for any protected object
The correct API call will be made based on the object id submitted
Multiple objects can be piped into this function so long as they contain the id required for lookup

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
```

This will return all snapshot (backup) data for the virtual machine id of "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"

### -------------------------- EXAMPLE 2 --------------------------
```
Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017'
```

This will return the closest matching snapshot to March 21st, 2017 for any virtual machine named "Server1"

### -------------------------- EXAMPLE 3 --------------------------
```
Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date (Get-Date)
```

This will return the closest matching snapshot to the current date and time for any virtual machine named "Server1"

### -------------------------- EXAMPLE 4 --------------------------
```
Get-RubrikDatabase 'DB1' | Get-RubrikSnapshot -OnDemandSnapshot
```

This will return the details on any on-demand (user initiated) snapshot to for any database named "DB1"

## PARAMETERS

### -id
Rubrik id of the protected object

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

### -CloudState
Filter results based on where in the cloud the snapshot lives

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
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
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
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

