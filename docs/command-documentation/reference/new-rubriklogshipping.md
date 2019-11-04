---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikLogShipping
schema: 2.0.0
---

# New-RubrikLogShipping

## SYNOPSIS

Create a log shipping configuration within Rubrik

## SYNTAX

```text
New-RubrikLogShipping [-id] <String> [[-state] <String>] [-DisconnectStandbyUsers]
 [-targetDatabaseName] <String> [[-targetDataFilePath] <String>] [[-targetLogFilePath] <String>]
 [-targetInstanceId] <String> [[-TargetFilePaths] <PSObject[]>] [[-MaxDataStreams] <Int32>]
 [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION

Create a log shipping configuration within Rubrik

## EXAMPLES

### EXAMPLE 1

```text
$RubrikDatabase = Get-RubrikDatabase -Name 'AthenaAM1-SQL16-1-2016' -Hostname am1-sql16-1
```

$RubrikSQLInstance = Get-RubrikSQLInstance -Hostname am1-chrilumn-w1 -instance MSSQLSERVER New-RubrikLogShipping -id $RubrikDatabase.id -state 'STANDBY' -targetDatabaseName 'AthenaAM1-SQL16-1-2016' -targetDataFilePath 'c:\sqldata' -targetLogFilePath 'c:\sqldata' -targetInstanceId $RubrikSQLInstance.id -Verbose

## PARAMETERS

### -id

Rubrik identifier of database to be exported

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

### -state

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisconnectStandbyUsers

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: shouldDisconnectStandbyUsers

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -targetDatabaseName

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -targetDataFilePath

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

### -targetLogFilePath

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -targetInstanceId

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetFilePaths

Advanced Mode - Array of hash tables for file reloaction.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxDataStreams

Number of parallel streams to copy data

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
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
Position: 9
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
Position: 10
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Chris Lumnah Twitter: lumnah GitHub: clumnah

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikLogShipping](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/New-RubrikLogShipping)

