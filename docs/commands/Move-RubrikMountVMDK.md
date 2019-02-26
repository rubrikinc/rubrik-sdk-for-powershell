---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Move-RubrikMountVMDK.html
schema: 2.0.0
---

# Move-RubrikMountVMDK

## SYNOPSIS
Moves the VMDKs from a Live Mount to another VM

## SYNTAX

### Create
```
Move-RubrikMountVMDK [-SourceVMID <String>] [-SourceVM <String>] -TargetVM <String> [-Date <String>]
 [-ExcludeDisk <Array>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Destroy
```
Move-RubrikMountVMDK [-Cleanup <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.

## EXAMPLES

### EXAMPLE 1
```
Move-RubrikMountVMDK -SourceVMID (Get-RubrikVM -Name 'SourceVM').id -TargetVM 'TargetVM'
```

This will create a Live Mount using the latest snapshot of the VM named "SourceVM", using the VM's Rubrik ID.
The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

### EXAMPLE 2
```
Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM'
```

This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

### EXAMPLE 3
```
Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -Date '01/30/2016 08:00'
```

This will create a Live Mount using the January 30th 08:00AM snapshot of the VM named "SourceVM"
The Live Mount's VMDKs would then be presented to the VM named "TargetVM"
Note: The Date parameter will start at the time specified (in this case, 08:00am) and work backwards in time until it finds a snapshot.
Precise timing is not required.

### EXAMPLE 4
```
Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -ExcludeDisk @(0,1)
```

This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
Disk 0 and 1 (the first and second disks) would be excluded from presentation to the VM named "TargetVM"
Note: that for the "ExcludeDisk" array, the format is @(#,#,#,...) where each # represents a disk starting with 0.
Example: To exclude the first and third disks, the value would be @(0,2).
Example: To exclude just the first disk, use @(0).

### EXAMPLE 5
```
Move-RubrikMountVMDK -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'
```

This will remove the disk(s) and live mount, effectively reversing the initial request
This file is created each time the command is run and stored in the $HOME path as a text file
The file contains the TargetVM name, MountID value, and a list of all presented disks

## PARAMETERS

### -SourceVMID
Source virtual machine Rubrik ID to use as a live mount

```yaml
Type: String
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceVM
Source virtual machine to use as a Live Mount based on a previous backup

```yaml
Type: String
Parameter Sets: Create
Aliases: Name, VM

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetVM
Target virtual machine to attach the Live Mount disk(s)

```yaml
Type: String
Parameter Sets: Create
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
Backup date to use for the Live Mount
Will use the current date and time if no value is specified

```yaml
Type: String
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDisk
An array of disks to exclude from presenting to the target virtual machine
By default, all disks will be presented

```yaml
Type: Array
Parameter Sets: Create
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cleanup
The path to a cleanup file to remove the live mount and presented disks
The cleanup file is created each time the command is run and stored in the $HOME path as a text file with a random number value
The file contains the TargetVM name, MountID value, and a list of all presented disks

```yaml
Type: String
Parameter Sets: Destroy
Aliases:

Required: False
Position: Named
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Move-RubrikMountVMDK.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Move-RubrikMountVMDK.html)

