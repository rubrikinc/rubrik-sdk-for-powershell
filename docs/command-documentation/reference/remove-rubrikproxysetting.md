---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikproxysetting
schema: 2.0.0
---

# Remove-RubrikProxySetting

## SYNOPSIS
Removes Proxy Configuration from a Rubrik Cluster nodes

## SYNTAX

```
Remove-RubrikProxySetting [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes Proxy Configuration for either the cluster nodes

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikProxySetting
```

Removes the Rubrik Node Proxy Configuration for the current node

### EXAMPLE 2
```
Get-RubrikNodeProxyConfig | Remove-RubrikProxySetting -Verbose
```

Removes the current Rubrik Node Proxy configuration while displaying Verbose information

### EXAMPLE 3
```
Get-RubrikNode | Remove-RubrikProxySetting
```

Removes the Proxy configuration for all Rubrik Nodes retrieved by Get-RubrikNode

## PARAMETERS

### -Server
Rubrik server IP or FQDN

```yaml
Type: String
Parameter Sets: (All)
Aliases: ipAddress, NodeIPAddress

Required: False
Position: 1
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
Position: 2
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikproxysetting](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikproxysetting)

