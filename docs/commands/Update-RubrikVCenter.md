---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Update-RubrikVCenter.html
schema: 2.0.0
---

# Update-RubrikVCenter

## SYNOPSIS
Connects to Rubrik to refresh the metadata for the specified vCenter Server

## SYNTAX

```
Update-RubrikVCenter [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Update-RubrikVCenter cmdlet will refresh all vCenter metadata known to the connected Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVCenter -Name 'vcsa.domain.local' | Update-RubrikVCenter
```

This will refresh the vCenter metadata on the currently connected Rubrik cluster

### EXAMPLE 2
```
Get-RubrikVCenter | Update-RubrikVCenter
```

This will refresh the vCenter metadata for all connecter vCenter instances on the currently connected Rubrik cluster

## PARAMETERS

### -id
vCenter id value from the Rubrik Cluster

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Update-RubrikVCenter.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Update-RubrikVCenter.html)

