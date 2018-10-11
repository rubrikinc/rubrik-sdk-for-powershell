---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Stop-RubrikManagedVolumeSnapshot

## SYNOPSIS
Stops Rubrik Managed Volume snopshot

## SYNTAX

### SLA_Explicit
```
Stop-RubrikManagedVolumeSnapshot [-id <String>] [-Server <String>] [-SLA <String>] [-SLAID <String>]
 [-api <String>] [<CommonParameters>]
```

### SLA_Forever
```
Stop-RubrikManagedVolumeSnapshot [-id <String>] [-Server <String>] [-Forever] [-SLAID <String>] [-api <String>]
 [<CommonParameters>]
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
Position: Named
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
Position: Named
Default value: $global:RubrikConnection.server
Accept pipeline input: False
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

### -Forever
The snapshot will be retained indefinitely and available under Unmanaged Objects

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Forever
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
Position: Named
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
Position: Named
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

