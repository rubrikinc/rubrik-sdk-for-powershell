---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareDatastore.html
schema: 2.0.0
---

# Get-RubrikVMwareDatastore

## SYNOPSIS

Connects to Rubrik and retrieves a list of VMware datastores

## SYNTAX

```text
Get-RubrikVMwareDatastore [[-Name] <String>] [[-DatastoreType] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikVMwareDatastore cmdlet will retrieve VMware datastores known to an authenticated Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikVMwareDatastore
```

This will return a listing of all of the datastores known to a connected Rubrik cluster

### EXAMPLE 2

```text
Get-RubrikVMwareDatastore -Name 'vSAN'
```

This will return a listing of all of the datastores named 'vSAN' known to a connected Rubrik cluster

### EXAMPLE 3

```text
Get-RubrikVMwareDatastore -DatastoreType 'NFS'
```

This will return a listing of all of the NFS datastores known to a connected Rubrik cluster

## PARAMETERS

### -Name

Datastore Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatastoreType

Filter Datastore type

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareDatastore.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareDatastore.html)

