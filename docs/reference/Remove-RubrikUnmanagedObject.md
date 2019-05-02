---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUnmanagedObject.html
schema: 2.0.0
---

# Remove-RubrikUnmanagedObject

## SYNOPSIS
Removes one or more unmanaged objects known to a Rubrik cluster

## SYNTAX

```
Remove-RubrikUnmanagedObject [-id] <String> [-Type] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikUnmanagedObject cmdlet is used to remove unmanaged objects that have been stored in the cluster
In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikUnmanagedObject | Remove-RubrikUnmanagedObject
```

This will remove all unmanaged objects from the cluster

### EXAMPLE 2
```
Get-RubrikUnmanagedObject -Type 'WindowsFileset' | Remove-RubrikUnmanagedObject -Confirm:$false
```

This will remove any unmanaged objects related to filesets applied to Windows Servers and supress confirmation for each activity

### EXAMPLE 3
```
Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1' | Remove-RubrikUnmanagedObject
```

This will remove any unmanaged objects associated with any workload named "Server1" that is currently unprotected

## PARAMETERS

### -id
The id of the unmanaged object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: objectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the unmanaged object.
This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.

```yaml
Type: String
Parameter Sets: (All)
Aliases: objectType

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: 4
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUnmanagedObject.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUnmanagedObject.html)

