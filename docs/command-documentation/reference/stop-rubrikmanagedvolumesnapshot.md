---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Stop-RubrikManagedVolumeSnapshot
schema: 2.0.0
---

# Stop-RubrikManagedVolumeSnapshot

## SYNOPSIS
Stops Rubrik Managed Volume snopshot

## SYNTAX

```
Stop-RubrikManagedVolumeSnapshot [[-id] <String>] [[-Server] <String>] [[-SLA] <String>] [-Forever]
 [[-SLAID] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Stop-RubrikManagedVolumeSnapshot cmdlet is used to close a Rubrik Managed Volume
for read/write actions.

## EXAMPLES

### EXAMPLE 1
```
Stop-ManagedVolumeSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2
```

Close the specified managed volume for read/write operations

### EXAMPLE 2
```
Get-RubrikManagedVolume -name 'foo' | Stop-ManagedVolumeSnapshot
```

## PARAMETERS

### -id
Rubrik's Managed Volume id value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $global:RubrikConnection.server
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA
The SLA Domain in Rubrik

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forever
The snapshot will be retained indefinitely and available under Unmanaged Objects

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

### -SLAID
SLA id value

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Stop-RubrikManagedVolumeSnapshot](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Stop-RubrikManagedVolumeSnapshot)

