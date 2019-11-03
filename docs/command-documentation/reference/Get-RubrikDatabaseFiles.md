---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikDatabaseFiles
schema: 2.0.0
---

# Get-RubrikDatabaseFiles

## SYNOPSIS
Connects to Rubrik and retrieves all the data files for a SQL Server Database snapshot

## SYNTAX

### RecoveryDateTime
```
Get-RubrikDatabaseFiles [-Id] <String> [-RecoveryDateTime <DateTime>] [<CommonParameters>]
```

### Time
```
Get-RubrikDatabaseFiles [-Id] <String> [-time <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikDatabaseFiles cmdlet will return all the available databasem files for a database 
snapshot.
This is based on the recovery time for the database, as file locations could change
between snapshots and log backups.
If no date time is provided, the database's latest recovery
point will be used

***WARNING***
This is based on an internal endpoint and is subject to change by the REST API team.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikDatabaseFiles -id '11111111-2222-3333-4444-555555555555'
```

This will return files for database id  "11111111-2222-3333-4444-555555555555".

### EXAMPLE 2
```
Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -RecoveryDateTime (Get-Date).AddDays(-1)
```

This will return details on mount id "11111111-2222-3333-4444-555555555555" from a recovery point one day ago, assuming that recovery point exists.

### EXAMPLE 3
```
Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -time '2017-08-08T01:15:00Z'
```

This will return details on mount id "11111111-2222-3333-4444-555555555555" from UTC '2017-08-08 01:15:00', assuming that recovery point exists.

## PARAMETERS

### -Id
Rubrik's id of the mount

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

### -RecoveryDateTime
Recovery Point desired in the form of DateTime value

```yaml
Type: DateTime
Parameter Sets: RecoveryDateTime
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -time
Recovery Point desired in the form of a UTC string (yyyy-MM-ddTHH:mm:ss)

```yaml
Type: String
Parameter Sets: Time
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
Parameter Sets: Time
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
Parameter Sets: Time
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
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikDatabaseFiles](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikDatabaseFiles)

