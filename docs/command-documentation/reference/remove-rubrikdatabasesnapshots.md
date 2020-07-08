---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikdatabasesnapshots
schema: 2.0.0
---

# Remove-RubrikDatabaseSnapshots

## SYNOPSIS
Connects to Rubrik and removes all database snapshots for a given database.

## SYNTAX

```
Remove-RubrikDatabaseSnapshots [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-RubrikFilesetSnapshot cmdlet will request that the Rubrik API delete all snapshots for a given rubrik database.
The database must be unprotected for this operation to succeed.

## EXAMPLES

### EXAMPLE 1
```
Remove-RubrikDatabaseSnapshots -id '01234567-8910-1abc-d435-0abc1234d567'
```

This will attempt to remove all database snapshots for the database with an id of \`01234567-8910-1abc-d435-0abc1234d567\`

### EXAMPLE 2
```
Remove-RubrikDatabaseSnapshots -id '01234567-8910-1abc-d435-0abc1234d567' -Confirm:$false
```

This will attempt to remove all database snapshots for the database with an id of \`01234567-8910-1abc-d435-0abc1234d567\` without user confirmation

### EXAMPLE 3
```
Get-RubrikDatabase -id '1111-2222-3333' |  Remove-RubrikDatabaseSnapshots
```

This will attempt to remove all database snapshots for the database with an id of '1111-2222-3333'

## PARAMETERS

### -id
Database ID of the database to delete snapshots from

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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikdatabasesnapshots](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikdatabasesnapshots)

