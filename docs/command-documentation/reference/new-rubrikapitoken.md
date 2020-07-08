---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikapitoken
schema: 2.0.0
---

# New-RubrikAPIToken

## SYNOPSIS
Creates a new Rubrik API Token.

## SYNTAX

```
New-RubrikAPIToken [[-OrganizationId] <String>] [[-Expiration] <Int32>] [[-Tag] <String>] [[-Server] <String>]
 [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikAPIToken cmdlet is used to generate a new API Token for the Rubrik cluster using the role and permissions of the currently logged in session.
The token can then be used in making API requests without having to resort to basic authorization.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikAPIToken
```

This will generate a new API Token named "API Token" that lasts for 60 minutes (1 hour).

### EXAMPLE 2
```
New-RubrikAPIToken -Expiration 2880 -Tag "2-Day Token"
```

This will generate a new API Token named "2-Day Token" that lasts for 2880 minutes (48 hours / 2 days).

### EXAMPLE 3
```
New-RubrikAPIToken -Expiration 10080 -Tag "Dev Org Weekly Token" -OrganizationId "Organization:::11111111-2222-3333-4444-555555555555"
```

This will generate a new API Token named "Dev Org Weekly Token" that lasts for 10080 minutes (7 days) in the organization matching id value "Organization:::11111111-2222-3333-4444-555555555555".
This assumes that the current session that is requested the token has authority in that organization.

## PARAMETERS

### -OrganizationId
Bind the new session to the specified organization.
When this parameter is not specified, the session will be bound to an organization chosen according to the user's preferences and authorizations.

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

### -Expiration
This value specifies an interval in minutes.
The token expires at the end of the interval.
By default, this value is 60 (1 hour).
This value cannot exceed 525600 (365 days).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 60
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Name assigned to the token.
The default value is "API Token".

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikapitoken](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikapitoken)

