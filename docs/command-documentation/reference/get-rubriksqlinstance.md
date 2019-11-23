---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSQLInstance
schema: 2.0.0
---

# Get-RubrikSQLInstance

## SYNOPSIS

Gets internal Rubrik object that represents a SQL Server instance

## SYNTAX

```text
Get-RubrikSQLInstance [[-Name] <String>] [[-SLA] <String>] [[-Hostname] <String>] [[-ServerInstance] <String>]
 [[-PrimaryClusterID] <String>] [[-id] <String>] [[-SLAID] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Returns internal Rubrik object that represents a SQL Server instance. This

## EXAMPLES

### EXAMPLE 1

```text
Get-RubrikSQLInstance -Name MSSQLSERVER
```

Retrieve all default SQL instances managed by Rubrik

### EXAMPLE 2

```text
Get-RubrikSQLInstance -ServerInstance msf-sql2016
```

Retrieve the default SQL instance on host msf-sql2016

### EXAMPLE 3

```text
Get-RubrikSQLInstance -Hostname msf-sql2016
```

Retrieves all the SQL instances on host msf-sql2016

### EXAMPLE 4

```text
Get-RubrikSQLInstance -PrimaryClusterID local
```

Only return SQLInstances of the Rubrik cluster that is hosting the current REST API session.

### EXAMPLE 5

```text
Get-RubrikSQLInstance -PrimaryClusterID 8b4fe6f6-cc87-4354-a125-b65e23cf8c90
```

Only return SQLInstances of the specified id of the Rubrik cluster that is hosting the current REST API session.

## PARAMETERS

### -Name

Name of the instance

```yaml
Type: String
Parameter Sets: (All)
Aliases: InstanceName

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLA

SLA Domain policy assigned to the database

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

### -Hostname

Name of the database host

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerInstance

ServerInstance name \(combined hostname\instancename\)

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

### -PrimaryClusterID

Filter the summary information based on the primarycluster\_id of the primary Rubrik cluster. Use: local as the primary\_cluster\_id of the Rubrik cluster that is hosting the current REST API session.

```yaml
Type: String
Parameter Sets: (All)
Aliases: primary_cluster_id

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id

Rubrik's database id value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SLAID

SLA id value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
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
Position: 8
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
Position: 9
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Fal for community usage Twitter: @Mike\_Fal GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSQLInstance](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikSQLInstance)

