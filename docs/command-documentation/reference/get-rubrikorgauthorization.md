---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikorgauthorization
schema: 2.0.0
---

# Get-RubrikOrgAuthorization

## SYNOPSIS
Returns a list of authorizations for the organization role.

## SYNTAX

```
Get-RubrikOrgAuthorization [[-id] <String>] [[-OrgID] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet returns the current list of authorizations for the organization role.
Organizations are used to support
Rubrik's multi-tenancy feature.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikOrgAuthorization
```

Infers the Organization of the current user and returns the list of authorizations for that Organization.

### EXAMPLE 2
```
Get-RubrikOrgAuthorization -ID Organization:::01234567-8910-1abc-d435-0abc1234d567
```

Returns the list of authorizations for the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567

### EXAMPLE 3
```
Get-RubrikOrganization | Get-RubrikOrgAuthorization
```

Returns a list of authorizations for all organizations on the current cluster

## PARAMETERS

### -id
Principal ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: principals

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OrgID
Organization ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: organization_id

Required: False
Position: 2
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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikorgauthorization](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikorgauthorization)

