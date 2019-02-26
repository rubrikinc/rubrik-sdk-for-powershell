---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikMount.html
schema: 2.0.0
---

# Set-RubrikMount

## SYNOPSIS
Powers on/off a live mounted virtual machine within a connected Rubrik vCenter.

## SYNTAX

```
Set-RubrikMount [-id] <String> [-PowerOn <Boolean>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikMount cmdlet is used to send a power on request to mounted virtual machine visible to a Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikMount -id '11111111-2222-3333-4444-555555555555' | Set-RubrikMount -PowerOn:$true
```

This will send a power on request to "Server1"

### EXAMPLE 2
```
Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Set-RubrikMount -PowerOn:$false
```

This will send a power off request to "Server1"

## PARAMETERS

### -id
Mount id

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

### -PowerOn
Configuration for the change power status request

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: powerStatus

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikMount.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikMount.html)

