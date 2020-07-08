---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriknasshare
schema: 2.0.0
---

# Set-RubrikNASShare

## SYNOPSIS
Change settings for a NAS share

## SYNTAX

### Credential (Default)
```
Set-RubrikNASShare -Id <String> [-Credential] <Object> [-ExportPoint <String>] [-Server <String>]
 [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UserPassword
```
Set-RubrikNASShare -Id <String> [-Username] <String> [-Password] <SecureString> [[-Domain] <SecureString>]
 [-ExportPoint <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Update NAS share settings that are configured in Rubrik, such as updating the export point or
change the NAS credentials

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -ExportPoint 'TEMP'
```

Update the NAS Share FOO with the export point of TEMP.

### EXAMPLE 2
```
Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -Credential (Get-Credential)
```

Update the NAS Share FOO with the credentials specified

## PARAMETERS

### -Id
NAS Share ID

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

### -Credential
New export point for the share

```yaml
Type: Object
Parameter Sets: Credential
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Username to assign to NAS Share

```yaml
Type: String
Parameter Sets: UserPassword
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Password for the Username provided

```yaml
Type: SecureString
Parameter Sets: UserPassword
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
Domain for the user

```yaml
Type: SecureString
Parameter Sets: UserPassword
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPoint
Rubrik server IP or FQDN

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
New NAS Share credential

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
Written by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal
Any other links you'd like here

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriknasshare](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriknasshare)

