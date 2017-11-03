---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Remove-RubrikMount

## SYNOPSIS
Connects to Rubrik and removes one or more live mounts

## SYNTAX

```
Remove-RubrikMount [-id] <String> [-Force] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove-RubrikMount -id '11111111-2222-3333-4444-555555555555'
```

This will remove mount id "11111111-2222-3333-4444-555555555555".

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikMount | Remove-RubrikMount
```

This will remove all mounted virtual machines.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Remove-RubrikMount
```

This will remove any mounts found using the virtual machine named "Server1" as a base reference.

## PARAMETERS

### -id
The Rubrik ID value of the mount

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

### -Force
Force unmount to deal with situations where host has been moved.

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

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
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
Position: 3
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

