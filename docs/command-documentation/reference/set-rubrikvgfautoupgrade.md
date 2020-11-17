---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvgfautoupgrade
schema: 2.0.0
---

# Set-RubrikVgfAutoUpgrade

## SYNOPSIS
Updates the Volume Group format auto upgrade settings on a Rubrik cluster

## SYNTAX

```
Set-RubrikVgfAutoUpgrade [[-migrateFastVirtualDiskBuild] <String>]
 [[-maxFullMigrationStoragePercentage] <Int32>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikVgfAutoUpgrade cmdlet is used to update the Volume Group format auto upgrade settings to a Rubrik cluster.
There are two configurations available:
  - 'migrateFastVirtualDiskBuild', or 'AutoUpgradeMode', is a string-type
    flag that controls the use of the fast VHDX builder during
    volume group migration.
When the value of the flag is 'Error-Only,'
    the volume group uses the fast VHDX builder when a pre-5.1 volume group
    backup operation fails during the fetch phase.
When the value of the flag
    is 'All,' the volume group uses the fast VHDX builder the next time the
    volume group is backed up.
Any other value disables the fast VHDX builder.
    This flag is used in combination with the maxFullMigrationStoragePercentage
    value.
  - 'maxFullMigrationStoragePercentage', is an integer which specifies a
    percentage of the total storage space.
When performing a full volume group
    backup operation would bring the total used storage space above this
    threshold, the cluster takes incremental backups instead.
This value is
    used in combination with the migrateFastVirtualDiskBuild flag.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild 'All'
```

This will set the cluster configuration to automatically upgrade format for all Volume Groups.

### EXAMPLE 2
```
Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild 'Error-Only'
```

This will set the cluster configuration to automatically upgrade for Volume Groups that have a failure during the last backup.

### EXAMPLE 3
```
Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild 'None'
```

This will set the cluster configuration to not automatically upgrade format for any Volume Groups.

### EXAMPLE 4
```
Set-RubrikVgfAutoUpgrade -maxFullMigrationStoragePercentage 70
```

This will set the cluster configuration to allow automatic upgrade only when the projected cluster space usage after upgrade does not exceed 70% of total cluster storage.

### EXAMPLE 5
```
Set-RubrikVgfAutoUpgrade -migrateFastVirtualDiskBuild 'Error-Only' -maxFullMigrationStoragePercentage 70
```

This will set both configurations on the cluster.

## PARAMETERS

### -migrateFastVirtualDiskBuild
Mode of automatic upgrade

```yaml
Type: String
Parameter Sets: (All)
Aliases: AutoUpgradeMode

Required: False
Position: 1
Default value: None
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
Filter the report based on whether the Volume Group used fast VHDX format for its latest snapshot.

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
Written by Feng Lu for community usage
github: fenglu42

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvgfautoupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvgfautoupgrade)

