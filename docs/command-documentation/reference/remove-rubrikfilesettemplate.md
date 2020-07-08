---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesettemplate
schema: 2.0.0
---

# Remove-RubrikFilesetTemplate

## SYNOPSIS
Removes Fileset Template from a Rubrik Cluster

## SYNTAX

```
Remove-RubrikFilesetTemplate [-id] <String> [-PreserveSnapshots] [[-Server] <String>] [[-api] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes Fileset Template for either the cluster

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikFilesetTemplate -id FilesetTemplate:::1111
```

Removes the Rubrik Fileset Template

### EXAMPLE 2
```
Get-RubrikRubrikFilesetTemplate | Remove-RubrikFilesetTemplate -Verbose
```

Removes the templates supplied by Get-RubrikFilesetTemplate, while displaying Verbose information

### EXAMPLE 3
```
Remove-RubrikFilesetTemplate -id FilesetTemplate:::1111 -PreserveSnapshots:$false
```

Removes the Fileset Template and does not preserve existing snapshots

## PARAMETERS

### -id
The Rubrik ID value of the fileset

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PreserveSnapshots
When not specified, the default is to preserve snapshots, add -PreserverSnapshots:$false to delete existing snapshots

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: preserve_snapshots

Required: False
Position: Named
Default value: False
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
Position: 2
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
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesettemplate](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesettemplate)

