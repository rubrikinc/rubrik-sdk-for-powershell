---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfautoupgrade
schema: 2.0.0
---

# Get-RubrikVgfAutoUpgrade

## SYNOPSIS
Retrieves the Volume Group format auto upgrade settings from a Rubrik cluster

## SYNTAX

```
Get-RubrikVgfAutoUpgrade [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVgfAutoUpgrade cmdlet is used to retrieve the Volume Group format auto upgrade settings from a Rubrik cluster.
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
Get-RubrikVgfAutoUpgrade
```

This will return the Volume Group format auto upgrade settings from the connected cluster.

## PARAMETERS

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfautoupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvgfautoupgrade)

