---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikBlacout
schema: 2.0.0
---

# Set-RubrikBlackout

## SYNOPSIS

Connects to Rubrik and sets blackout \(stops/starts all snaps\)

## SYNTAX

```text
Set-RubrikBlackout [-Set] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikBlackout cmdlet will accept a flag of true/false to set cluster blackout

## EXAMPLES

### EXAMPLE 1

```text
Set-RubrikBlackout -Set:[$true/$false]
```

## PARAMETERS

### -Set

Rubrik blackout value

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: isGlobalBlackoutActive

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
Position: 1
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
Position: 2
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Pete Milanese for community usage Twitter: @pmilano1 GitHub: pmilano1

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikBlacout](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikBlacout)

