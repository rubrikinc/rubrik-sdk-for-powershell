---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/resume-rubriksla
schema: 2.0.0
---

# Resume-RubrikSLA

## SYNOPSIS
Resumes an existing Rubrik SLA Domain

## SYNTAX

### Query (Default)
```
Resume-RubrikSLA [-Name] <String> [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ID
```
Resume-RubrikSLA [-id] <String> [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Resume-RubrikSLA cmdlet will resume an existing SLA Domain with specified parameters.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikSLA -Name Gold | Resume-RubrikSLA
```

This will update the SLA Domain named "Gold" to resume backups

### EXAMPLE 2
```
Get-RubrikSLA -Name Gold | Resume-RubrikSLA
```

This will update the SLA Domain named "Gold" to resume backups

### EXAMPLE 3
```
Resume-RubrikSLA Gold -Verbose
```

This will resume the backups for the Gold SLA while displaying verbose information

## PARAMETERS

### -id
SLA id value from the Rubrik Cluster

```yaml
Type: String
Parameter Sets: ID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
SLA Domain Name

```yaml
Type: String
Parameter Sets: Query
Aliases: SLA

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: JaapBrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/resume-rubriksla](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/resume-rubriksla)

