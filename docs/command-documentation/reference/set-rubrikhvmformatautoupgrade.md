---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikhvmformatautoupgrade
schema: 2.0.0
---

# Set-RubrikHvmFormatAutoUpgrade

## SYNOPSIS
Updates the Hyper-V Virtual Machine format auto upgrade settings on a Rubrik cluster

## SYNTAX

```
Set-RubrikHvmFormatAutoUpgrade [[-migrateFastVirtualDiskBuild] <Boolean>]
 [[-maxFullMigrationStoragePercentage] <Int32>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikHvmFormatAutoUpgrade cmdlet is used to update the Hyper-V Virtual Machine format auto upgrade settings to a Rubrik cluster.
There are two configurations available:
  - 'migrateFastVirtualDiskBuild', or 'AutoUpgradeMode', is a boolean
    flag that controls the use of the fast VHDX builder during
    Hyper-V Virtual Machine migration.
When the value of the flag
    is true, the Hyper-V Virtual Machine uses the fast VHDX builder the next time the
    Hyper-V Virtual Machine is backed up.
A value of false disables the fast VHDX builder.
    This flag is used in combination with the maxFullMigrationStoragePercentage
    value.
  - 'maxFullMigrationStoragePercentage', is an integer which specifies a
    percentage of the total storage space.
When performing a full Hyper-V Virtual Machine
    backup operation would bring the total used storage space above this
    threshold, the cluster takes incremental backups instead.
This value is
    used in combination with the migrateFastVirtualDiskBuild flag.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $True
```

This will set the cluster configuration to automatically upgrade format for all Hyper-V Virtual Machines.

### EXAMPLE 2
```
Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $False
```

This will set the cluster configuration to not automatically upgrade format for any Hyper-V Virtual Machines.

### EXAMPLE 3
```
Set-RubrikHvmFormatAutoUpgrade -maxFullMigrationStoragePercentage 70
```

This will set the cluster configuration to allow automatic upgrade only when the projected cluster space usage after upgrade does not exceed 70% of total cluster storage.

### EXAMPLE 4
```
Set-RubrikHvmFormatAutoUpgrade -migrateFastVirtualDiskBuild $True -maxFullMigrationStoragePercentage 70
```

This will set both configurations on the cluster.

## PARAMETERS

### -migrateFastVirtualDiskBuild
Mode of automatic upgrade

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: AutoUpgradeMode

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -maxFullMigrationStoragePercentage
Maximum allowed cluster storage space usage if upgrade happens

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

### -Server
Filter the report based on whether the Hyper-V Virtual Machine used fast VHDX format for its latest snapshot.

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
Written by Abhinav Prakash for community usage
github: ab-prakash

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikhvmformatautoupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikhvmformatautoupgrade)

