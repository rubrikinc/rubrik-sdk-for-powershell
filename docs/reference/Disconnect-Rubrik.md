---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Disconnect-Rubrik.html
schema: 2.0.0
---

# Disconnect-Rubrik

## SYNOPSIS
Disconnects from a Rubrik cluster

## SYNTAX

```
Disconnect-Rubrik [[-id] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Disconnect-Rubrik function is used to disconnect from a Rubrik cluster.
This is done by supplying the bearer token and requesting that the session be deleted.

## EXAMPLES

### EXAMPLE 1
```
Disconnect-Rubrik -Confirm:$false
```

This will close the current session and invalidate the current session token without prompting for confirmation

### EXAMPLE 2
```
$rubrikConnection = $RubrikConnections[1]
```

Disconnect-Rubrik
This will close the second session and invalidate the second session token
Note: The $rubrikConnections variable holds session details on all established sessions
      The $rubrikConnection variable holds the current, active session
      If you wish to change sessions, simply update the value of $rubrikConnection to another session held within $rubrikConnections

## PARAMETERS

### -id
Session id

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Me
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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Disconnect-Rubrik.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Disconnect-Rubrik.html)

