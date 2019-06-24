---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikMount.html
schema: 2.0.0
---

# New-RubrikMount

## SYNOPSIS
Create a new Live Mount from a protected VM

## SYNTAX

```
New-RubrikMount [-id] <String> [[-HostID] <String>] [[-MountName] <String>] [[-DatastoreName] <String>]
 [[-DisableNetwork] <Boolean>] [[-RemoveNetworkDevices] <Boolean>] [[-PowerOn] <Boolean>] [[-Server] <String>]
 [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikMount -id '11111111-2222-3333-4444-555555555555'
```

This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555"
The original virtual machine's name will be used along with a date and index number suffix
The virtual machine will NOT be powered on upon completion of the mount operation

### EXAMPLE 2
```
New-RubrikMount -id '11111111-2222-3333-4444-555555555555' -MountName 'Mount1' -PowerOn -RemoveNetworkDevices
```

This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555" and name the mounted virtual machine "Mount1"
The virtual machine will be powered on upon completion of the mount operation but without any virtual network adapters

### EXAMPLE 3
```
Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/01/2017 01:00' | New-RubrikMount -MountName 'Mount1' -DisableNetwork
```

This will create a new mount based on the closet snapshot found on March 1st, 2017 @ 01:00 AM and name the mounted virtual machine "Mount1"
The virtual machine will NOT be powered on upon completion of the mount operation

## PARAMETERS

### -id
Rubrik id of the snapshot

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

### -HostID
ID of host for the mount to use

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

### -MountName
Name of the mounted VM

```yaml
Type: String
Parameter Sets: (All)
Aliases: vmName

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatastoreName
Name of the data store to use/create on the host

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

### -DisableNetwork
Whether the network should be disabled on mount.This should be set true to avoid ip conflict in case of static IPs.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveNetworkDevices
Whether the network devices should be removed on mount.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerOn
Whether the VM should be powered on after mount.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
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
Position: 8
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
Position: 9
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikMount.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikMount.html)

