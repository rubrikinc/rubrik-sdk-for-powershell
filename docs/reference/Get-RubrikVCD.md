---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikVCD

## SYNOPSIS
Connect to Rubrik and retrieve the current Rubrik vCD settings

## SYNTAX

```
Get-RubrikVCD [[-Name] <String>] [[-Hostname] <String>] [[-Status] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
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

## PARAMETERS

### -Name
vCD Cluster Name

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

### -Hostname
vCD Cluster Hostname

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

### -Status
vCD Cluster Status

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

