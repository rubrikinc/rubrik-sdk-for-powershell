---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabaserecoverypoint
schema: 2.0.0
---

# Get-RubrikDatabaseRecoveryPoint

## SYNOPSIS
Retrieves a date time combination either from Rubrik API calls or with entered information that is formated for use by other Rubrik cmdlets

## SYNTAX

### Latest
```
Get-RubrikDatabaseRecoveryPoint [-id] <String> [-Latest] [<CommonParameters>]
```

### LastFull
```
Get-RubrikDatabaseRecoveryPoint [-id] <String> [-LastFull] [<CommonParameters>]
```

### RestoreTime
```
Get-RubrikDatabaseRecoveryPoint [-id] <String> [-RestoreTime <DateTime>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikDatabaseRecoveryPoint cmdlet is used to pull date time combination from either Get-RubrikDatabase or Get-RubrikSnapshot based on a database ID.
When we pull the value from those cmdlets, we will use that in Export-RubrikDatabase, New-RubrikDatabaseMount, Restore-RubrikDatabase.
We will also pass in a time
to get back a date time combination or an exact time.
ALl results will be returned back in UTC so that the cmdlets can properly perform their functions.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikDatabaseRecoveryPoint -id "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -Latest
```

This will return back a date time combination that prepresents the latest recovery point known to Rubrik about this database.
This will include the last snapshot and any transaction log backup taken since that 
last snapshot was taken.

### EXAMPLE 2
```
Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -LastFull
```

This will return back a date time combination that prepresents the recovery point known to Rubrik about this database based on the most recent snapshot taken.

### EXAMPLE 3
```
Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -RestoreTime 02:00:00
```

This will return back a date time combination that represents todays date at 2am, but converted to UTC.
The time entered into the RestoreTime field will be in local time.

### EXAMPLE 4
```
Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -RestoreTime "2019-10-19 20:00:00"
```

This will return back a date time combination that represents the local date time value entered into the RestoreTme field, converted to UTC.

## PARAMETERS

### -id
Rubrik's database id value

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

### -Latest
A time  to which the database should be restored to.
latest:             This will tell Rubrik to export the database to the latest recovery point Rubrik knows about
                    This will include the last full and any logs to get to the latest recovery point

```yaml
Type: SwitchParameter
Parameter Sets: Latest
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastFull
{{ Fill LastFull Description }}

```yaml
Type: SwitchParameter
Parameter Sets: LastFull
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestoreTime
A time  to which the database should be restored to.
Format:             (HH:MM:SS.mmm) at the point in time specified within the last 24 hours
Format:             Any valid \<value\> that PS Get-Date supports in: "Get-Date -Date \<Value\>"
    Example: "2018-08-01T02:00:00.000Z" restores back to 2AM on August 1, 2018 UTC.

```yaml
Type: DateTime
Parameter Sets: RestoreTime
Aliases:

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
Written by Chris Lumnah for community usage
Twitter: @lumnah
GitHub: clumnah

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabaserecoverypoint](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabaserecoverypoint)

