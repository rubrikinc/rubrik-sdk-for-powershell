---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvolumegroupmount
schema: 2.0.0
---

# New-RubrikVolumeGroupMount

## SYNOPSIS
Create a new live mount of a protected volume group

## SYNTAX

```
New-RubrikVolumeGroupMount -TargetHost <String> -VolumeGroupSnapshot <Object> [-ExcludeDrives <Array>]
 [-ExcludeMountPoints <Array>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikVolumeGroupMount cmdlet is used to create a new volume group mount on the TargetHost of the selected Snapshot.
The Snapshot object contains the snapID and all drives that are included in the snapshot.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikVolumeGroupMount -TargetHost 'Restore-Server1' -VolumeGroupSnapshot $snap -ExcludeDrives -$DrivestoExclude
```

This will create a new VolumeGroup Mount on Restore-Server1 with the values specified in $snap & $DrivestoExclude

### EXAMPLE 2
```
$snapshot = Get-RubrikVolumeGroup "MyVolumeGroup" | Get-RubrikSnapshot -Latest
```

New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeDrives @("D","E")
This will create a new VolumeGroup Mount on MyTargetHostName with the latest snapshot retrieved in the first line, while exlcluding drives D & E

New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeMountPoint @("C:\MFAPDB05Log\")
This will create a new VolumeGroup Mount on MyTargetHostName with the latest snapshot retrieved in the first line, while exlcluding the volume mounted on C:\MFAPDB05Log\

New-RubrikVolumeGroupMount -TargetHost "MyTargetHostName" -VolumeGroupSnapshot $snapshot -ExcludeMountPoint @("Log")
To exclude all MountPoints with a certain string

## PARAMETERS

### -TargetHost
Target host to attach the Live Mount disk(s)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VolumeGroupSnapshot
Rubrik VolumeGroup Snapshot Array

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDrives
Rubrik server IP or FQDN

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeMountPoints
{{ Fill ExcludeMountPoints Description }}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
{{ Fill Server Description }}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pierre Flammer for community usage
Twitter: @PierreFlammer

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvolumegroupmount](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvolumegroupmount)

