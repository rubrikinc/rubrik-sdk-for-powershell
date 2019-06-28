---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/
schema: 2.0.0
---

# Set-RubrikNASShare

## SYNOPSIS
Change settings for a NAS share

## SYNTAX

```
Set-RubrikNASShare [-Id] <String> [[-ExportPoint] <String>] [[-Credential] <PSCredential>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
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

## PARAMETERS

### -Id
NAS Share ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExportPoint
New export point for the share

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
New NAS Share credential

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
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
Position: 4
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
Position: 5
Default value: $global:RubrikConnection.api
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

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

