---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesetsnapshot
schema: 2.0.0
---

# Remove-RubrikFilesetSnapshot

## SYNOPSIS
Connects to Rubrik and removes an expired fileset snapshot available for garbage collection.

## SYNTAX

```
Remove-RubrikFilesetSnapshot [-id] <String> [[-location] <String>] [[-Server] <String>] [[-api] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikFilesetSnapshot cmdlet will request that the Rubrik API delete an an expired fileset snapshot.
The snapshot must a snapshot from a fileset that is not assigned to an SLA Domain.

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikFilesetSnapshot -id '01234567-8910-1abc-d435-0abc1234d567'
```

This will attempt to remove fileset snapshot (backup) data with the snapshot id \`01234567-8910-1abc-d435-0abc1234d567\`

### EXAMPLE 2
```
Remove-RubrikFilesetSnapshot -id '01234567-8910-1abc-d435-0abc1234d567' -location local -Confirm:$false
```

This will attempt to remove the local copy of the fileset snapshot (backup) data with the snapshot id \`01234567-8910-1abc-d435-0abc1234d567\` without user intevention

### EXAMPLE 3
```
Get-RubrikFileset Fileset1 | Get-RubrikSnapshot -Date '03/21/2017' | Remove-RubrikFilesetSnapshot
```

This will attempt to remove any snapshot from \`03/21/2017\` for the fileset named \`Fileset1\`.

## PARAMETERS

### -id
ID of the snapshot to delete

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

### -location
Snapshot location to delete, either "local" or "all".
Defaults to "all"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: All
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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesetsnapshot](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesetsnapshot)

