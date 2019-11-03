---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikManagedVolume
schema: 2.0.0
---

# Set-RubrikManagedVolume

## SYNOPSIS
Sets Rubrik Managed Volume properties

## SYNTAX

```
Set-RubrikManagedVolume -id <String> [-VolumeSize <Int64>] [-exportConfig <PSObject[]>] [-SLAID <String>]
 [-SLA <String>] [-Name <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikMakangedVolume cmdlet is used to update certain settings for a Rubrik Managed Volume.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -SLA 'Gold'
```

Protect the specified managed volume with the 'Gold' SLA domain

### EXAMPLE 2
```
Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -VolumeSize 536870912000
```

### EXAMPLE 3
```
Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -Name 'NewName'
```

Resize the specified managed volume to 536870912000 bytes (500GB)

## PARAMETERS

### -id
Rubrik's Managed Volume id value

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

### -VolumeSize
Size of the Managed Volume in Bytes

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -exportConfig
Export config, such as host hints and host name patterns

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID
SLA Domain ID for the database

```yaml
Type: String
Parameter Sets: (All)
Aliases: ConfiguredSlaDomainId

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
The SLA Domain name in Rubrik

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Managed Volume Name

```yaml
Type: String
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
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikManagedVolume](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikManagedVolume)

