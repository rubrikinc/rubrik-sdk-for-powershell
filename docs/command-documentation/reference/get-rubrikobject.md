---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikobject
schema: 2.0.0
---

# Get-RubrikObject

## SYNOPSIS
Retrieve summary information for all objects that are registered with a Rubrik cluster.

## SYNTAX

### FilterByName
```
Get-RubrikObject -NameFilter <String> [-IncludeObjectType <String[]>] [-ExcludeObjectType <String[]>]
 [-IncludeObjectClass <String[]>] [-ExcludeObjectClass <String[]>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### FilterByID
```
Get-RubrikObject -IdFilter <String> [-IncludeObjectType <String[]>] [-ExcludeObjectType <String[]>]
 [-IncludeObjectClass <String[]>] [-ExcludeObjectClass <String[]>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikObject cmdlet is used to retrive information on one or more objects existing within the Rubrik cluster.
Rubrik objects consist of any type of VM, Host, Fileset, NAS Share, cloud instance, etc.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikObject -NameFilter 'test*'
```

This will return all known objects within the Rubrik cluster matching the given name pattern

### EXAMPLE 2
```
Get-RubrikObject -IDFilter '1111-2222-3333-*'
```

This will return all known objects within the Rubrik cluster matching the given id pattern

### EXAMPLE 3
```
Get-RubrikObject -NameFilter 'test*' -IncludeObjectClass VirtualMachines
```

This will return all known Virtual Machines within the Rubrik cluster matching the given name pattern

### EXAMPLE 4
```
Get-RubrikObject -NameFilter 'test*' -ExcludeObjectClass Databases
```

This will return all known objects within the Rubrik cluster except those related to databases matching the given name pattern

### EXAMPLE 5
```
Get-RubrikObject -NameFilter 'test*' -IncludeObjectType VMwareVM,OracleDB
```

This will return all known VMware VMs and Oracle Databases within the Rubrik cluster matching the given name pattern

### EXAMPLE 6
```
Get-RubrikObject -NameFilter 'test*' -ExcludeObjectType NutanixVM,APIToken
```

This will return all known objects within the Rubrik cluster except Nutanix VMs and API tokens matching the given name pattern

## PARAMETERS

### -NameFilter
Filter by Name

```yaml
Type: String
Parameter Sets: FilterByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IdFilter
Filter by ID

```yaml
Type: String
Parameter Sets: FilterByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeObjectType
Filter Objects to include

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeObjectType
Filter Objects to exclude

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeObjectClass
Filter Object Classes to include

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeObjectClass
Filter Object Classes to exclude

```yaml
Type: String[]
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikobject](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikobject)

