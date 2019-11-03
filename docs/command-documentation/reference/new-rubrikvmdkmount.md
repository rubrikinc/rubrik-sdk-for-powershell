---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'https://github.com/rubrikinc/PowerShell-Module'
schema: 2.0.0
---

# New-RubrikVMDKMount

## SYNOPSIS

## SYNTAX

```text
New-RubrikVMDKMount [[-SnapshotID] <String>] -TargetVM <String> [-AllDisks] [-VLAN <Int32>] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1

```text
PS C:\> {{ Add example code here }}
```

## PARAMETERS

### -AllDisks

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

### -Server

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

### -SnapshotID

```yaml
Type: String
Parameter Sets: (All)
Aliases: id

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetVM

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

### -VLAN

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -api

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

