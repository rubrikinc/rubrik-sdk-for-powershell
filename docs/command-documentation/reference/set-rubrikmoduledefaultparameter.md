---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduledefaultparameter
schema: 2.0.0
---

# Set-RubrikModuleDefaultParameter

## SYNOPSIS
Creates or modifies a default value for a given parameter

## SYNTAX

### NameValue (Default)
```
Set-RubrikModuleDefaultParameter -ParameterName <String> -ParameterValue <String> [<CommonParameters>]
```

### Sync
```
Set-RubrikModuleDefaultParameter [-Sync] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikModuleDefaultParameter will allow users to create default values for common parameters within the Rubrik SDK for PowerShell
These values are stored within the users options file located in $home.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId -ParameterValue local
```

Sets the PrimaryClusterId value to always equate to local when not specified.
If PrimaryClusterId is already defined to have a default value it will be updated, if not, it will be created.

### EXAMPLE 2
```
Set-RubrikModuleDefaultParameter -Sync
```

Syncs changes to the user options file to the current PowerShell session

## PARAMETERS

### -ParameterName
Parameter Name

```yaml
Type: String
Parameter Sets: NameValue
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ParameterValue
Parameter Value

```yaml
Type: String
Parameter Sets: NameValue
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sync
Sync any manual changes within user option file to current PowerShell session

```yaml
Type: SwitchParameter
Parameter Sets: Sync
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduledefaultparameter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduledefaultparameter)

