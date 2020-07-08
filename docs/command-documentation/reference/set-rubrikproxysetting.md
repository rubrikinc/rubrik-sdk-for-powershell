---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikproxysetting
schema: 2.0.0
---

# Set-RubrikProxySetting

## SYNOPSIS
Set a Rubrik Proxy Settings

## SYNTAX

```
Set-RubrikProxySetting [-proxyhostname] <String> [-Protocol] <String> [[-port] <Int32>] [[-Username] <String>]
 [[-password] <SecureString>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikProxySetting cmdlet will set proxy configuration information for the cluster nodes.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikProxySetting -Host build.rubrik.com -Port 8080 -Protocol HTTPS
```

Set the Cluster proxy configuration to the settings listed

### EXAMPLE 2
```
Set-RubrikProxySetting -Host build.rubrik.com -Port 8080 -Protocol HTTPS -UserName jaapbrasser -Password $SecurePW
```

Set the cluster proxy information to the settings specified in the function parameter

## PARAMETERS

### -proxyhostname
The proxy FQDN or ip address

```yaml
Type: String
Parameter Sets: (All)
Aliases: host

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Protocol
The protocal that is used by proxy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -port
Optional, port number for Proxy Configuration

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Optional parameter, user name for proxy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -password
Optional parameter, password for proxy

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: ipAddress, NodeIPAddress

Required: False
Position: 6
Default value: $global:RubrikConnection.server
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -api
API version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikproxysetting](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikproxysetting)

