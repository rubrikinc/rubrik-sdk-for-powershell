---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIToken.html
schema: 2.0.0
---

# Get-RubrikAPIToken

## SYNOPSIS

Connects to Rubrik and retrieves a list of generated API tokens

## SYNTAX

```text
Get-RubrikAPIToken [[-UserId] <String>] [[-Tag] <String>] [[-OrganizationId] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RubrikAPIToken cmdlet is used to pull a list of generated API tokens from the Rubrik cluster.

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikAPIToken
```

This will return all generated API tokens belonging to the currently logged in user.

### EXAMPLE 2

```text
Get-RubrikAPIToken -tag roxie
```

This will return all generated API tokens belonging to the currently logged in user with a 'roxie' tag.

### EXAMPLE 3

```text
Get-RubrikAPIToken -organizationId 1111-2222-3333
```

This will return all generated API tokens assigned to the currently logged in user with the specified organization id.

## PARAMETERS

### -UserId

UserID to retrieve tokens from - defaults to currently logged in user

```yaml
Type: String
Parameter Sets: (All)
Aliases: user_id

Required: False
Position: 1
Default value: $rubrikconnection.userId
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag

Tag assigned to the API Token

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

### -OrganizationId

Organization ID the API Token belongs to.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIToken.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIToken.html)

