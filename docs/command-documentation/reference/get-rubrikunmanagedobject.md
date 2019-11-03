---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUnmanagedObject
schema: 2.0.0
---

# Get-RubrikUnmanagedObject

## SYNOPSIS
Retrieves details on one or more unmanaged objects known to a Rubrik cluster

## SYNTAX

```
Get-RubrikUnmanagedObject [[-Name] <String>] [[-Status] <String>] [[-Type] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikUnmanagedObject cmdlet is used to pull details on any unmanaged objects that has been stored in the cluster
In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikUnmanagedObject -Type 'WindowsFileset'
```

This will return details on any filesets applied to Windows Servers that have unmanaged snapshots associated

### EXAMPLE 2
```
Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1'
```

This will return details on any objects named "Server1" that are currently unprotected and have unmanaged snapshots associated

## PARAMETERS

### -Name
Search object by object name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: search_value

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Filter by the type of the object.
If not specified, will return all objects.
Valid attributes are Protected, Relic and Unprotected

```yaml
Type: String
Parameter Sets: (All)
Aliases: unmanaged_status

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The type of the unmanaged object.
This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.

```yaml
Type: String
Parameter Sets: (All)
Aliases: object_type

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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUnmanagedObject](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikUnmanagedObject)

