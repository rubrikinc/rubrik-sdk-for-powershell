---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLoginBanner
schema: 2.0.0
---

# Get-RubrikLoginBanner

## SYNOPSIS

Connects to Rubrik and retrieves the current login banner text

## SYNTAX

```text
Get-RubrikLoginBanner [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikLoginBanner cmdlet will retrieve the current login banner text. This does require authentication.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikLoginBanner
```

This will return the login banner text of the currently connected cluster.

## PARAMETERS

### -Server

Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 2
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLoginBanner](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikLoginBanner)

