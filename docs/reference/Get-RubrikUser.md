---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikUser.html
schema: 2.0.0
---

# Get-RubrikUser

## SYNOPSIS
Gets settings of a Rubrik user

## SYNTAX

### Query
```
Get-RubrikUser [-Username <String>] [-AuthDomainId <String>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### ID
```
Get-RubrikUser -Id <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikUser cmdlet is used to query the Rubrik cluster to retrieve a list of settings around a Rubrik user account.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikUser
```

This will return settings of all of the user accounts (local and LDAP) configured within the Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikUser -authDomainId 'local'
```

This will return settings of all of the user accounts belonging to the local authoriation domain.

### EXAMPLE 3
```
Get-RubrikUser -username 'john.doe'
```

This will return settings for the user account with the username of john.doe configured within the Rubrik cluster.

### EXAMPLE 4
```
Get-RubrikUser -authDomainId '1111-222-333'
```

This will return settings of all of the user accounts belonging to the specified authoriation domain.

### EXAMPLE 5
```
Get-RubrikUser -id '1111-22222-33333-4444-5555'
```

This will return detailed information about the user with the specified ID.

## PARAMETERS

### -Username
Username to filter on

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthDomainId
AuthDomainId to filter on

```yaml
Type: String
Parameter Sets: Query
Aliases: auth_domain_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
User ID

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: Named
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
Position: Named
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
Position: Named
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikUser.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikUser.html)

