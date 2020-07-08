---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksmbdomain
schema: 2.0.0
---

# Get-RubrikSmbDomain

## SYNOPSIS
Connects to Rubrik and retrieves information around the SMB Domains configured in the currently authenticated cluster

## SYNTAX

```
Get-RubrikSmbDomain [[-Name] <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikSmbDomain cmdlet will retrieve information around the configured SMB Domains in the currently authenticated cluster

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikSmbDomain
```

This will return the details around the configured SMB Domains within the authenticated Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikSmbDomain -Name 'domain.local'
```

This will return the details related to the domain.local SMB Domain configured within the Rubrik cluster.

## PARAMETERS

### -Name
Name of the SMB Domain to retrieve

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksmbdomain](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksmbdomain)

