---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksyslogserver
schema: 2.0.0
---

# Get-RubrikSyslogServer

## SYNOPSIS
Connects to Rubrik and retrieves the Syslog server settings for the currently authenticated cluster

## SYNTAX

```
Get-RubrikSyslogServer [[-Name] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikSyslogServer cmdlet will retrieve the Syslog server settings for the currently authenticated cluster

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikSyslogServer
```

This will return the Syslog server configuration for the authenticated Rubrik cluster.

### EXAMPLE 2
```
Get-RubrikSyslogServer -Name 'syslog.domain.local'
```

This will return the Syslog server configuration for the syslog server named 'syslog.domain.local' for the authenticated Rubrik cluster.

## PARAMETERS

### -Name
Syslog server hostname to retrieve settings for

```yaml
Type: String
Parameter Sets: (All)
Aliases: hostname

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksyslogserver](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksyslogserver)

