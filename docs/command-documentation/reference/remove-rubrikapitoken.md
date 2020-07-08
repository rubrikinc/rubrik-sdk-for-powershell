---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikapitoken
schema: 2.0.0
---

# Remove-RubrikAPIToken

## SYNOPSIS
Removes a Rubrik API Token.

## SYNTAX

```
Remove-RubrikAPIToken [-TokenId] <Array> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikAPIToken cmdlet is used to remove an API Token from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikAPIToken -TokenId "11111111-2222-3333-4444-555555555555"
```

This will remove the API Token matching id "11111111-2222-3333-4444-555555555555".

### EXAMPLE 2
```
Remove-RubrikAPIToken -TokenId ("11111111-2222-3333-4444-555555555555","aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
```

This will remove the API Tokens matching id values "11111111-2222-3333-4444-555555555555" and "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" in one request.

## PARAMETERS

### -TokenId
API Token ID value(s).
For multiple ID values, encase the values in parenthesis and separate each ID with a comma.
See the examples for more details.

```yaml
Type: Array
Parameter Sets: (All)
Aliases: tokenIds

Required: True
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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikapitoken](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikapitoken)

