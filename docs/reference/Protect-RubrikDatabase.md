---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikDatabase.html
schema: 2.0.0
---

# Protect-RubrikDatabase

## SYNOPSIS
Connects to Rubrik and assigns an SLA to a database

## SYNTAX

### SLA_Explicit
```
Protect-RubrikDatabase -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Unprotected
```
Protect-RubrikDatabase -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Inherit
```
Protect-RubrikDatabase -id <String> [-Inherit] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Protect-RubrikDatabase cmdlet will update a database's SLA Domain assignment within the Rubrik cluster.
The SLA Domain contains all policy-driven values needed to protect workloads.
Note that this function requires the Database ID value, not the name of the database, since database names are not unique across hosts.
It is suggested that you first use Get-RubrikDatabase to narrow down the one or more database / instance / hosts to protect, and then pipe the results to Protect-RubrikDatabase.
You will be asked to confirm each database you wish to protect, or you can use -Confirm:$False to skip confirmation checks.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikDatabase "DB1" | Protect-RubrikDatabase -SLA 'Gold'
```

This will assign the Gold SLA Domain to any database named "DB1"

### EXAMPLE 2
```
Get-RubrikDatabase "DB1" -Instance "MSSQLSERVER" | Protect-RubrikDatabase -SLA 'Gold' -Confirm:$False
```

This will assign the Gold SLA Domain to any database named "DB1" residing on an instance named "MSSQLSERVER" without asking for confirmation

## PARAMETERS

### -id
Database ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SLA
The SLA Domain in Rubrik

```yaml
Type: String
Parameter Sets: SLA_Explicit
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DoNotProtect
Removes the SLA Domain assignment

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Unprotected
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Inherit
Inherits the SLA Domain assignment from a parent object

```yaml
Type: SwitchParameter
Parameter Sets: SLA_Inherit
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAID
SLA id value

```yaml
Type: String
Parameter Sets: (All)
Aliases: configuredSlaDomainId

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
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikDatabase.html](http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikDatabase.html)

