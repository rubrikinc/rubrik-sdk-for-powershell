---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# New-RubrikSnapshot

## SYNOPSIS
Takes an on-demand Rubrik snapshot of a protected object

## SYNTAX

### SLA_Explicit
```
New-RubrikSnapshot -id <String> [-SLA <String>] [-ForceFull] [-SLAID <String>] [-Server <String>]
 [-api <String>] [-WhatIf] [-Confirm]
```

### SLA_Unprotected
```
New-RubrikSnapshot -id <String> [-DoNotProtect] [-ForceFull] [-SLAID <String>] [-Server <String>]
 [-api <String>] [-WhatIf] [-Confirm]
```

### SLA_Inherit
```
New-RubrikSnapshot -id <String> [-Inherit] [-ForceFull] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific object (virtual machine, database, fileset, etc.)

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikVM 'Server1' | New-RubrikSnapshot -Inherit
```

This will trigger an on-demand backup for any virtual machine named "Server1" using the existing SLA domain

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikFileset 'C_Drive' | New-RubrikSnapshot -SLA 'Gold'
```

This will trigger an on-demand backup for any fileset named "C_Drive" using the "Gold" SLA Domain

### -------------------------- EXAMPLE 3 --------------------------
```
Get-RubrikDatabase 'DB1' | New-RubrikSnapshot -ForceFull -Inherit
```

This will trigger an on-demand backup for any database named "DB1" and force the backup to be a full rather than an incremental.

## PARAMETERS

### -id
Rubrik's id of the object

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

### -ForceFull
Whether to force a full snapshot or an incremental.
Only valid with MSSQL Databases.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: forceFullSnapshot

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
Aliases: 

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

