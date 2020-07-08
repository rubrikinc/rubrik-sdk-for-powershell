---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhostvolume
schema: 2.0.0
---

# Get-RubrikHostVolume

## SYNOPSIS
Connects to Rubrik and retrieves information of volumes connected to a host

## SYNTAX

```
Get-RubrikHostVolume [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHostVolume cmdlet will retrieve all volume of the selected windows host that are currently present

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHostVolume -id Host:::a9d9a5ac-ed22-4723-b329-74db48c93e03
```

### EXAMPLE 2
```
Get-RubrikHost -name 2016.flammi.home | Get-RubrikHostVolume
```

## PARAMETERS

### -id
Host ID

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pierre Flammer for community usage
Twitter: @PierreFlammer
GitHub: Pierre-PvF

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhostvolume](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhostvolume)

