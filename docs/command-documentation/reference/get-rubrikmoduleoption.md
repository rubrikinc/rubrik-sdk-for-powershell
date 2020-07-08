---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduleoption
schema: 2.0.0
---

# Get-RubrikModuleOption

## SYNOPSIS
Retrieves a customized Rubrik module option

## SYNTAX

```
Get-RubrikModuleOption [[-OptionName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikModuleOption will retrieve one or more options within the users home directory

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikModuleOption
```

Retrieves all the customized module options

### EXAMPLE 2
```
Get-RubrikModuleOption -OptionName CredentialPath
```

Retrieves the CredentialPath customized module option

## PARAMETERS

### -OptionName
Option Name

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduleoption](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmoduleoption)

