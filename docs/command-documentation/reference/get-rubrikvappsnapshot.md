---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvappsnapshot
schema: 2.0.0
---

# Get-RubrikVAppSnapshot

## SYNOPSIS
Retrieves details on one or more virtual machines known to the Rubrik cluster as a vCD-managed vApp

## SYNTAX

```
Get-RubrikVAppSnapshot [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikVAppSnapshot cmdlet pulls detailed information from a vCD vApp snapshot

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVAppSnapshot -id '01234567-8910-1abc-d435-0abc1234d567'
```

This returns details on the specific snapshot.

## PARAMETERS

### -id
ID of the snapshot

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvappsnapshot](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikvappsnapshot)

