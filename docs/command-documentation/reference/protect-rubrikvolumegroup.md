---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikvolumegroup
schema: 2.0.0
---

# Protect-RubrikVolumeGroup

## SYNOPSIS
Connects to Rubrik and assigns an SLA to a VolumeGroup

## SYNTAX

### None (Default)
```
Protect-RubrikVolumeGroup -id <String> [-SLAID <String>] [-ExcludeDrive <Array>] [-ExcludeIDs <Array>]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Explicit
```
Protect-RubrikVolumeGroup -id <String> [-SLA <String>] [-SLAID <String>] [-ExcludeDrive <Array>]
 [-ExcludeIDs <Array>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Unprotected
```
Protect-RubrikVolumeGroup -id <String> [-DoNotProtect] [-SLAID <String>] [-ExcludeDrive <Array>]
 [-ExcludeIDs <Array>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Protect-RubrikVolumeGroup cmdlet will assign a SLA Domain to Volumes on a window host.
The SLA Domain contains all policy-driven values needed to protect workloads.
You can first use Get-RubrikVolumeGroup to get the one volume group you want to protect, and then pipe the results to Protect-RubrikVolumeGroup.
You can exclude volumes by specifiying the driveletter or the volumeID.

## EXAMPLES

### EXAMPLE 1
```
Protect-RubrikVolumeGroup -id VolumeGroup:::2038fecb-745b-4d2d-8a71-cf2fc0d0be80 -SLA 'Gold'
```

This will assign the Gold SLA Domain to the specified Volume Group, including all volumes presently on the system

### EXAMPLE 2
```
Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold'
```

This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system

### EXAMPLE 3
```
Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold' -ExcludeDrive C,E
```

This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system except for  the C and E drives

### EXAMPLE 4
```
Get-RubrikVolumeGroup -hostname ad.flammi.home | Protect-RubrikVolumeGroup -SLA 'Gold' -ExcludeIDs 824fd711-ad69-4b56-bb83-613b0125f178
```

This will assign the Gold SLA Domain to the volume group belonging to the specified hostname, including all volumes presently on the system excpt for the disks with the specified IDs

## PARAMETERS

### -id
VolumeGroup ID

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

### -SLA
The SLA Domain in Rubrik

```yaml
Type: String
Parameter Sets: SLA_Explicit
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotProtect
Removes the SLA Domain assignment

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Unprotected
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID
SLA id value

```yaml
Type: String
Parameter Sets: (All)
Aliases: configuredSlaDomainId

Required: False
Position: Named
Default value: (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$true)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDrive
Specifiy MountPoints to be excluded

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

### -ExcludeIDs
Specifiy IDs to be excluded (alternative to MountPoints)

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pierre Flammer for community usage
Twitter: @PierreFlammer
GitHub: Pierre-PvF

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikvolumegroup](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikvolumegroup)

