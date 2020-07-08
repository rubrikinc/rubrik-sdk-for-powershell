---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknetworkthrottle
schema: 2.0.0
---

# Get-RubrikNetworkThrottle

## SYNOPSIS
Connects to Rubrik and retrieves network throttling information for a given cluster

## SYNTAX

```
Get-RubrikNetworkThrottle [[-ThrottleType] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikNetworkThrottle cmdlet will retrieve information around replication and archive network throttling of a given cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNetworkThrottle
```

This will return the information around both the archival and replication network throttling within the authenticated Rubrik cluster.

## PARAMETERS

### -ThrottleType
Type of network throttling to retrieve

```yaml
Type: String
Parameter Sets: (All)
Aliases: resource_id

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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknetworkthrottle](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknetworkthrottle)

