---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/reset-rubriklogshipping
schema: 2.0.0
---

# Reset-RubrikLogShipping

## SYNOPSIS
Reseed a secondary database

## SYNTAX

```
Reset-RubrikLogShipping [-id] <String> [[-state] <String>] [-DisconnectStandbyUsers] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
Reseed a secondary database

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikLogShipping -PrimaryDatabaseName 'AthenaAM1-SQL16-1-2016' -SecondaryDatabaseName 'AthenaAM1-SQL16-1-2016' | Reset-RubrikLogShipping -state STANDBY -DisconnectStandbyUsers
```

## PARAMETERS

### -id
{{ Fill id Description }}

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

### -state
{{ Fill state Description }}

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

### -DisconnectStandbyUsers
{{ Fill DisconnectStandbyUsers Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: shouldDisconnectStandbyUsers

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Lumnah 
Twitter: lumnah
GitHub: clumnah

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/reset-rubriklogshipping](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/reset-rubriklogshipping)

