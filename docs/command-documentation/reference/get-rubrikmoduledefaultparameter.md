---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduledefaultparameter
schema: 2.0.0
---

# Get-RubrikModuleDefaultParameter

## SYNOPSIS
Retrieves the default parameter values

## SYNTAX

```
Get-RubrikModuleDefaultParameter [[-ParameterName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikModuleDefaultParameter will retrieve the default parameter values configured within the users options file.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikModuleDefaultParameter
```

Retrieves all the default parameter values

### EXAMPLE 2
```
Get-RubrikModuleDefaultParameter -ParameterName PrimaryClusterId
```

Retrieves the PrimaryClusterId default parameter value

## PARAMETERS

### -ParameterName
Parameter Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduledefaultparameter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduledefaultparameter)

