---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikvgfupgrade
schema: 2.0.0
---

# Invoke-RubrikVgfUpgrade

## SYNOPSIS
Connects to Rubrik and sets the forceFull flag of any number of Volume Groups that needs upgrade

## SYNTAX

```
Invoke-RubrikVgfUpgrade [-VGList] <String[]> [-notPrintingDetail] [[-Server] <String>] [[-api] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-RubrikVgfUpgrade cmdlet will update the forceFull flag of a given list of Volume Groups.
If these Volume Groups are using the SMB backup method, their forceFull flag will be set, and they will be upgraded to use the fast VHDX method in the next backup.

## EXAMPLES

### EXAMPLE 1
```
Invoke-RubrikVgfUpgrade -VGList VolumeGroup:::e0a04776-ab8e-45d4-8501-8da658221d74, VolumeGroup:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will set the forceFull flag of the given volume groups, if they need upgrade

### EXAMPLE 2
```
Get-RubrikVolumeGroup -hostname ad.flammi.home | Invoke-RubrikVgfUpgrade
```

This will set the forceFull flag of the Volume Group belonging to the specified hostname, if it needs upgrade

## PARAMETERS

### -VGList
VolumeGroup ID

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -notPrintingDetail
Print details during confirmation

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

### -api
API version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Written by Feng Lu for community usage
github: fenglu42

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikvgfupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikvgfupgrade)

