---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcenter
schema: 2.0.0
---

# Get-RubrikVCenter

## SYNOPSIS
Connects to Rubrik and retrieves the current Rubrik vCenter settings

## SYNTAX

```
Get-RubrikVCenter [[-Name] <String>] [[-Server] <String>] [[-id] <String>] [[-PrimaryClusterID] <String>]
 [-DetailedObject] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVCenter cmdlet will retrieve the all vCenter settings actively running on the system.
This does require authentication.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVCenter
```

This will return the vCenter settings on the currently connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikVCenter -DetailedObject
```

This will return the detailed vCenter settings from currently connected Rubrik cluster

## PARAMETERS

### -Name
vCenter Name

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

### -id
vCenter id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedObject
DetailedObject will retrieved the detailed Nutanix VM object, the default behavior of the API is to only retrieve a subset of the full Nutanix VM object unless we query directly by ID.
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
Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcenter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcenter)

