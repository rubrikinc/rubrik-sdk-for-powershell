---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikHost
schema: 2.0.0
---

# Get-RubrikHost

## SYNOPSIS
Retrieve summary information for all hosts that are registered with a Rubrik cluster.

## SYNTAX

```
Get-RubrikHost [-Name <String>] [-Type <String>] [-PrimaryClusterID <String>] [-id <String>] [-DetailedObject]
 [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHost cmdlet is used to retrive information on one or more hosts that are being protected with the Rubrik Backup Service or directly as with the case of NAS shares.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHost
```

This will return all known hosts

### EXAMPLE 2
```
Get-RubrikHost -Hostname 'Server1'
```

This will return details on any hostname matching "Server1"

### EXAMPLE 3
```
Get-RubrikHost -Type 'Windows' -PrimaryClusterID 'local'
```

This will return details on all Windows hosts that are being protected by the local Rubrik cluster

### EXAMPLE 4
```
Get-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
```

This will return details specifically for the host id matching "Host:::111111-2222-3333-4444-555555555555"

### EXAMPLE 5
```
Get-RubrikHost -Name myserver01 -DetailedObject
```

This will return the Host object with all properties, including additional details such as information around the Volume Filter Driver if applicable.
Using this switch parameter may negatively affect performance

## PARAMETERS

### -Name
Retrieve hosts with a host name matching the provided name.
The search type is infix

```yaml
Type: String
Parameter Sets: (All)
Aliases: Hostname

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Filter the summary information based on the operating system type.
Accepted values are 'Windows', 'Linux', 'ANY', 'NONE'.
Use NONE to only return information for hosts templates that do not have operating system type set.
Use ANY to only return information for hosts that have operating system type set.

```yaml
Type: String
Parameter Sets: (All)
Aliases: operating_system_type

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrimaryClusterID
Filter the summary information based on the primarycluster_id of the primary Rubrik cluster.
Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_cluster_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
ID of the registered host

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
DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID.
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikHost](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikHost)

