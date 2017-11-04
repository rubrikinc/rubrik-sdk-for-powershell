---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Get-RubrikDatabaseMount

## SYNOPSIS
Connects to Rubrik and retrieves details on mounts for a SQL Server Database

## SYNTAX

```
Get-RubrikDatabaseMount [[-Id] <String>] [[-SourceDatabaseId] <String>] [[-SourceDatabaseName] <String>]
 [[-TargetInstanceId] <String>] [[-MountedDatabaseName] <String>] [[-Server] <String>] [[-api] <String>]
```

## DESCRIPTION
The Get-RubrikMount cmdlet will accept one of several different query parameters
and retireve the database Live Mount information for that criteria.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RubrikDatabaseMount
```

This will return details on all mounted databases.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555'
```

This will return details on mount id "11111111-2222-3333-4444-555555555555".

### -------------------------- EXAMPLE 3 --------------------------
```
Get-RubrikDatabaseMount -source_database_id (Get-RubrikDatabase -HostName FOO -Instance MSSQLSERVER -Database BAR).id
```

This will return details for any mounts found using the id value from a database named BAR on the FOO default instance.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-RubrikDatabaseMount -source_database_name BAR
```

This returns any mounts where the source database is named BAR.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-RubrikDatabaseMount -mounted_database_name BAR_LM
```

This returns any mounts with the name BAR_LM

## PARAMETERS

### -Id
Rubrik's id of the mount

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceDatabaseId
Filters live mounts by database source id

```yaml
Type: String
Parameter Sets: (All)
Aliases: Source_Database_Id

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SourceDatabaseName
Filters live mounts by database source name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Source_Database_Name

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetInstanceId
Filters live mounts by database source name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Target_Instance_Id

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MountedDatabaseName
Filters live mounts by database source name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Mounted_Database_Name, MountName

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
Aliases: 

Required: False
Position: 6
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
Position: 7
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

