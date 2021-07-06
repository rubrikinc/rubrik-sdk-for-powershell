---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatautoupgrade
schema: 2.0.0
---

# Get-RubrikHvmFormatAutoUpgrade

## SYNOPSIS
Retrieves the HyperV Virtual Machine format auto upgrade settings from a Rubrik cluster

## SYNTAX

```
Get-RubrikHvmFormatAutoUpgrade [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHvmFormatAutoUpgrade cmdlet is used to retrieve the HyperV Virtual Machine format auto upgrade settings from a Rubrik cluster.
There are two configurations available:
  - 'migrateFastVirtualDiskBuild' is a boolean flag that controls the use of 
      the fast VHDX builder during Hyper-V virtual machine migration.
When
      the flag is 'true', the Hyper-V VM uses the fast VHDX builder the 
      next time, VM is backed up.
A value of false disables the fast VHDX
      builder.
This flag is used in combination with the 
      maxFullMigrationStoragePercentage value.
  - 'maxFullMigrationStoragePercentage', is an integer which specifies a
      percentage of the total available storage space.
When performing a
      full hyperv VM backup operation would bring the total used
      storage space above this threshold, the cluster takes incremental backups
      instead.
This value is used in combination with the
      migrateFastVirtualDiskBuild flag.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHvmFormatAutoUpgrade
```

This will return the HyperV Virtual Machine format auto upgrade settings from the connected cluster.

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
Written by Abhinav Prakash for community usage
github: ab-prakash

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatautoupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatautoupgrade)

