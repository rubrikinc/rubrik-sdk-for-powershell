---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Protect-RubrikVM

## SYNOPSIS
Connects to Rubrik and assigns an SLA to a virtual machine

## SYNTAX

### SLA_Explicit
```
Protect-RubrikVM -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm]
```

### SLA_Unprotected
```
Protect-RubrikVM -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm]
```

### SLA_Inherit
```
Protect-RubrikVM -id <String> [-Inherit] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm]
```

## DESCRIPTION
The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
The SLA Domain contains all policy-driven values needed to protect workloads.
Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikVM "VM1" | Protect-RubrikVM -SLA 'Gold'
```

This will assign the Gold SLA Domain to any virtual machine named "VM1"

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikVM "VM1" -SLA Silver | Protect-RubrikVM -SLA 'Gold' -Confirm:$False
```

This will assign the Gold SLA Domain to any virtual machine named "VM1" that is currently assigned to the Silver SLA Domain
without asking for confirmation

## PARAMETERS

### -id
Virtual machine ID

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

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

