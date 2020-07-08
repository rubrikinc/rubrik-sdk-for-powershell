---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikmoduledefaultparameter
schema: 2.0.0
---

# Remove-RubrikModuleDefaultParameter

## SYNOPSIS
Removes a defined default value for a parameter

## SYNTAX

### RemoveSingle (Default)
```
Remove-RubrikModuleDefaultParameter [-ParameterName] <String> [<CommonParameters>]
```

### RemoveAll
```
Remove-RubrikModuleDefaultParameter [-All] [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikModuleDefaultParameter remove the default value for a specified parameter defined within the users options file.

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId
```

This will remove the PrimaryClusterId default value from the user home file.
Changes take place immediately.

### EXAMPLE 2
```
Remove-RubrikModuleDefaultParameter -All
```

This will remove all default parameters defined within the users options file.
Note: This does not affect the default value for Credential defined with the CredentialPath module option

## PARAMETERS

### -ParameterName
Parameter Name

```yaml
Type: String
Parameter Sets: RemoveSingle
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -All
Remove all default parameter values

```yaml
Type: SwitchParameter
Parameter Sets: RemoveAll
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikmoduledefaultparameter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikmoduledefaultparameter)

