---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwaredatastore
schema: 2.0.0
---

# Get-RubrikVMwareDatastore

## SYNOPSIS
Connects to Rubrik and retrieves a list of VMware datastores

## SYNTAX

```
Get-RubrikVMwareDatastore [[-Name] <String>] [-id <String>] [-DatastoreType <String>] [-DetailedObject]
 [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVMwareDatastore cmdlet will retrieve VMware datastores known to an authenticated Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVMwareDatastore
```

This will return a listing of all of the datastores known to a connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikVMwareDatastore -Name 'vSAN'
```

This will return a listing of all of the datastores named 'vSAN' known to a connected Rubrik cluster

### EXAMPLE 3
```
Get-RubrikVMwareDatastore -Name 'vSAN' -DetailedObject
```

This will return a listing of all of the datastores named 'vSAN' known to a connected Rubrik cluster with fully detailed objects

### EXAMPLE 4
```
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

### -id
Datastore id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DatastoreType
Filter Datastore type

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

### -DetailedObject
DetailedObject will retrieved the detailed VMware Datastore object, the default behavior of the API is to only retrieve a subset of the full VMware Datastore object unless we query directly by ID.
Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwaredatastore](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvmwaredatastore)

