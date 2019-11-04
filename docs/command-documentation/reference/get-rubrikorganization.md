---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikOrganization
schema: 2.0.0
---

# Get-RubrikOrganization

## SYNOPSIS

Returns a list of all organizations.

## SYNTAX

```text
Get-RubrikOrganization [[-id] <String>] [[-name] <String>] [-isGlobal] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns all the organizations within Rubrik. Organizations are used to support Rubrik's multi-tenancy feature.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikOrganization
```

Returns a complete list of all Rubrik organizations.

### EXAMPLE 2

```text
Get-RubrikOrganization -isGlobal:$false
```

Returns a list of non global of all Rubrik organizations.

## PARAMETERS

### -id

Organization ID

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

### -name

Organization Name

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

### -isGlobal

Filter results on if the org is global or not

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: is_global

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Fal Twitter: @Mike\_Fal GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikOrganization](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikOrganization)

