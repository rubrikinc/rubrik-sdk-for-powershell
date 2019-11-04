---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Protect-RubrikVApp
schema: 2.0.0
---

# Protect-RubrikVApp

## SYNOPSIS

Connects to Rubrik and assigns an SLA to a vCD vApp

## SYNTAX

### None \(Default\)

```text
Protect-RubrikVApp -id <String> [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### SLA\_Explicit

```text
Protect-RubrikVApp -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### SLA\_Unprotected

```text
Protect-RubrikVApp -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### SLA\_Inherit

```text
Protect-RubrikVApp -id <String> [-Inherit] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The Protect-RubrikVApp cmdlet will update a vCD vApp's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values needed to protect workloads. Note that this function requires the vApp ID value and not the vApp name. This is because vApp names may not be unique across clusters. It is suggested that you first use Get-RubrikVApp to narrow down the one or more vApps to protect, and then pipe the results to Protect-RubrikVApp. You will be asked to confirm each vApp you wish to protect, or you can use -Confirm:$False to skip confirmation checks.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikVApp "vApp1" | Protect-RubrikVApp -SLA 'Gold'
```

This will assign the Gold SLA Domain to any vApp named "vApp1"

### EXAMPLE 2

```text
Get-RubrikVApp "vApp1" -SLA 'Silver' | Protect-RubrikVApp -SLA 'Gold' -Confirm:$False
```

This will assign the Gold SLA Domain to any vApp named "vApp1" that is currently assigned to the Silver SLA Domain without asking for confirmation

## PARAMETERS

### -id

vApp ID

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
Default value: (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$true)
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Protect-RubrikVApp](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Protect-RubrikVApp)

