---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcd
schema: 2.0.0
---

# Get-RubrikVCD

## SYNOPSIS
Connect to Rubrik and retrieve the current Rubrik vCD settings

## SYNTAX

### Query (Default)
```
Get-RubrikVCD [[-Name] <String>] [-Hostname <String>] [-Status <String>] [-DetailedObject] [-Server <String>]
 [-api <String>] [<CommonParameters>]
```

### ID
```
Get-RubrikVCD [-Id] <String> [-Hostname <String>] [-Status <String>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVCD cmdlet retrieves all vCD settings actively running on the system.
This requires authentication.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVCD
```

This returns the vCD settings on the currently connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikVCD -Name 'My vCD Cluster'
```

This returns the vCD settings on the currently connected Rubrik cluster matching the name 'My vCD Cluster'

### EXAMPLE 3
```
Get-RubrikVCD -Hostname 'vcd.example.com'
```

This returns the vCD settings on the currently connected Rubrik cluster matching the hostname 'vcd.example.com'

### EXAMPLE 4
```
Get-RubrikVCD -Status 'Connected'
```

This returns the vCD settings on the currently connected Rubrik cluster with the status of 'Connected'

### EXAMPLE 5
```
Get-RubrikVCD -DetailedObject
```

This returns the full set of settings of the vCD clusters on the currently connected Rubrik cluster

## PARAMETERS

### -Id
ID of the VCD Cluster to retrieve

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
vCD Cluster Name

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hostname
vCD Cluster Hostname

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

### -Status
vCD Cluster Status

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
DetailedObject will retrieved the detailed VCD object, the default behavior of the API is to only retrieve a subset of the full VCD object unless we query directly by ID.
Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

```yaml
Type: SwitchParameter
Parameter Sets: Query
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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcd](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvcd)

