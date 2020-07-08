---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikguestoscredential
schema: 2.0.0
---

# Get-RubrikGuestOSCredential

## SYNOPSIS
Connects to Rubrik and retrieves the Guest OS credentials stored within a cluster

## SYNTAX

### Query (Default)
```
Get-RubrikGuestOSCredential [[-Username] <String>] [-Domain <String>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### ID
```
Get-RubrikGuestOSCredential [-Id] <String> [-Domain <String>] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikGuestOSCredential cmdlet will retrieve information around the Guest OS Credentials stored within a given cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikGuestOSCredential
```

This will return all of the guest os crendentials stored within the currently authenticated cluster

### EXAMPLE 2
```
Get-RubrikGuestOSCredential -username administrator
```

This will return all of the guest os crendentials stored within the currently authenticated cluster with a username of administrator

### EXAMPLE 3
```
Get-RubrikGuestOSCredential -domain "domain.local"
```

This will return all of the guest os crendentials belonging to the domain.local domain stored within the currently authenticated cluster

## PARAMETERS

### -Id
ID of the Guest OS Credential to retrieve

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
Username of the Guest OS Crential to retrieve

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
Domain to retrieve Guest OS Credentials from

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikguestoscredential](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikguestoscredential)

