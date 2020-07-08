---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikfileset
schema: 2.0.0
---

# Protect-RubrikFileset

## SYNOPSIS
Connects to Rubrik and assigns an SLA to a fileset

## SYNTAX

### SLA_Explicit
```
Protect-RubrikFileset -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SLA_Unprotected
```
Protect-RubrikFileset -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Protect-RubrikFileset cmdlet will update a fileset's SLA Domain assignment within the Rubrik cluster.
The SLA Domain contains all policy-driven values needed to protect data.
Note that this function requires the fileset ID value, not the name of the fileset, since fileset names are not unique across clusters.
It is suggested that you first use Get-RubrikFileset to narrow down the one or more filesets to protect, and then pipe the results to Protect-RubrikFileset.
You will be asked to confirm each fileset you wish to protect, or you can use -Confirm:$False to skip confirmation checks.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikFileset 'C_Drive' | Protect-RubrikFileset -SLA 'Gold'
```

This will assign the Gold SLA Domain to any fileset named "C_Drive"

### EXAMPLE 2
```
Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -Confirm:$False
```

This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" without asking for confirmation

## PARAMETERS

### -id
Fileset ID

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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikfileset](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubrikfileset)

