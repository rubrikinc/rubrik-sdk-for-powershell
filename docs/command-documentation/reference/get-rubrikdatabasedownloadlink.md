---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabasedownloadlink
schema: 2.0.0
---

# Get-RubrikDatabaseDownloadLink

## SYNOPSIS
Create a download link to retrieve SQL Database files from snapshot

## SYNTAX

```
Get-RubrikDatabaseDownloadLink [-id] <String> [-SnapshotId] <String> [[-Server] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikDatabaseDownloadLink cmdlet creates a download link containing the SQL database files (mdf/ldf) of a given snapshot

## EXAMPLES

### EXAMPLE 1
```
$db = Get-RubrikDatabase AdventureWorks
```

$snapshot = $db | Get-RubrikSnapshot -Date '01/01/22'
$url = Get-RubrikDatabaseDownloadLink -id $db.id -SnapshotId $snapshot.id

Will create a download link for the mdf/ldf files contained within the AdventureWorks database snapshot closest to January 1, 2021

### EXAMPLE 2
```
$db = Get-RubrikDatabase AdventureWorks
```

$url = Get-RubrikDatabaseDownloadLink -id $db.id -SnapshotId "Latest"

Will create a download link for the mdf/ldf files contained within the latest AdventureWorks database snapshot

## PARAMETERS

### -id
SQL Database ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: DatabaseId

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SnapshotId
Snapshot ID

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabasedownloadlink](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdatabasedownloadlink)

