---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduleoption
schema: 2.0.0
---

# Set-RubrikModuleOption

## SYNOPSIS
Sets an option value within the users option file

## SYNTAX

### NameValue (Default)
```
Set-RubrikModuleOption [-OptionName] <String> [-OptionValue] <String> [<CommonParameters>]
```

### Defaults
```
Set-RubrikModuleOption [-Default] [<CommonParameters>]
```

### Sync
```
Set-RubrikModuleOption [-Sync] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikModuleOption will set an option value within the users option value and immediately apply the change.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikModuleOption -OptionName ApplyCustomViewDefinitions -OptionValue $false
```

This will disable the application of custom view definitions to returned objects, instead displaying a complete list of properties.

### EXAMPLE 2
```
Get-Credential | Export-CliXml -Path c:\creds\creds.xml
```

Set-RubrikModuleOption -OptionName CredentialPath -OptionValue "c:\creds\creds.xml"

This will create a default credential file to be used with Connect-Rubrik only.
Encrypted credentials will be stored on the local filesystem and automatically sent to Connect-Rubrik by applying them to the global $PSDefaultParameterValues variable

### EXAMPLE 3
```
Set-RubrikModuleOption -OptionName CredentialPath -OptionValue $null
```

This will remove the application of sending default credentials to Connect-Rubrik.
Note: It will not remove any generated credential files.

### EXAMPLE 4
```
Set-RubrikModuleOption -Default
```

This will reset all Rubrik module options to their default values

### EXAMPLE 5
```
Set-RubrikModuleOption -Sync
```

This will sync any changes made to the user option file manually to the current PowerShell session.

### EXAMPLE 6
```
Set-RubrikModuleOption -OptionName DefaultWebRequestTimeOut -OptionValue 30
```

Changes the default timeout for request to the Rubrik cluster to 30 seconds

## PARAMETERS

### -OptionName
Option name to change

```yaml
Type: String
Parameter Sets: NameValue
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OptionValue
Desired value for option

```yaml
Type: String
Parameter Sets: NameValue
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default
Reset all Module Options to default values

```yaml
Type: SwitchParameter
Parameter Sets: Defaults
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sync
Apply manual changes from JSON file to session

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduleoption](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikmoduleoption)

