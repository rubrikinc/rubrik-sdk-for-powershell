---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# New-RubrikFileset

## SYNOPSIS
{required: high level overview}

## SYNTAX

```
New-RubrikFileset [-TemplateID] <String> [[-HostID] <String>] [[-ShareID] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
{required: more detailed description of the function's purpose}

## EXAMPLES

### EXAMPLE 1
```
New-RubrikFileset -TemplateID '1111-1111-1111-1111' -HostID 'Host::::2222-2222-2222-2222'
```

Creates a new fileset on the specified host, using the selected template.

### EXAMPLE 2
```
New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id
```

Creates a new fileset for the BAR NAS, using the FOO template.

## PARAMETERS

### -TemplateID
Fileset Template ID to use for the new fileset

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostID
HostID - Used for Windows or Linux Filesets

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

### -ShareID
ShareID - used for NAS shares

```yaml
Type: String
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by {required}
Twitter: {optional}
GitHub: {optional}
Any other links you'd like here

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

