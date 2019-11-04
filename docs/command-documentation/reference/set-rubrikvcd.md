---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: 'https://github.com/rubrikinc/PowerShell-Module'
schema: 2.0.0
---

# Set-RubrikVCD

## SYNOPSIS

Connects to Rubrik and modifies an existing vCD connection

## SYNTAX

### None \(Default\)

```text
Set-RubrikVCD -id <String> [-Hostname <String>] [-UpdateCreds] [-SLAID <String>] [-Server <String>]
 [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA\_Explicit

```text
Set-RubrikVCD -id <String> [-Hostname <String>] [-UpdateCreds] [-SLA <String>] [-SLAID <String>]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA\_Unprotected

```text
Set-RubrikVCD -id <String> [-Hostname <String>] [-UpdateCreds] [-DoNotProtect] [-SLAID <String>]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA\_Inherit

```text
Set-RubrikVCD -id <String> [-Hostname <String>] [-UpdateCreds] [-Inherit] [-SLAID <String>] [-Server <String>]
 [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikVCD cmdlet modifies an existing vCloud Director connection on the system. This requires authentication.

## EXAMPLES

### EXAMPLE 1

```text
Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -SLA "Bronze"
```

This will update the vCD cluster settings on the Rubrik cluster and assign the 'Bronze' SLA on the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

### EXAMPLE 2

```text
Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -DoNotProtect
```

This will update the vCD cluster settings on the Rubrik cluster and clear the SLA assignment on the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

### EXAMPLE 3

```text
Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567 -Hostname newserver.company.com
```

This will update the vCD cluster settings on the Rubrik cluster to assign a new hostname to the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

### EXAMPLE 4

```text
Set-RubrikVCD -ID Vcd:::01234567-8910-1abc-d435-0abc1234d567
```

This will update the vCD cluster settings on the Rubrik cluster to update the credentials used to connect to the vCD cluster with ID "Vcd:::01234567-8910-1abc-d435-0abc1234d567"

## PARAMETERS

### -id

vCD Instance ID

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

### -Hostname

vCD Hostname \(FQDN\)

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

### -UpdateCreds

Updates vCD Credentials

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

### -SLA

The SLA Domain in Rubrik

```yaml
Type: String
Parameter Sets: SLA_Explicit
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotProtect

Removes the SLA Domain assignment

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Unprotected
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inherit

Inherits the SLA Domain assignment from a parent object

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Inherit
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID

SLA id value

```yaml
Type: String
Parameter Sets: (All)
Aliases: configuredSlaDomainId

Required: False
Position: Named
Default value: (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect)
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

Written by Matt Elliott for community usage Twitter: @NetworkBrouhaha GitHub: shamsway

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

