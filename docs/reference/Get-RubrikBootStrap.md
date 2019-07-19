---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap
schema: 2.0.0
---

# Get-RubrikBootStrap

## SYNOPSIS
Connects to Rubrik cluster and retrieves the bootstrap process progress.

## SYNTAX

```
Get-RubrikBootStrap [[-id] <String>] [[-Server] <String>] [[-RequestId] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function is created to pull the status of a cluster bootstrap request.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikBootStrap -server 169.254.11.25 -requestid 1
```

This will return the bootstrap status of the job with the requested ID.

## PARAMETERS

### -id
ID of the Rubrik cluster or me for self

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Me
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequestId
Bootstrap Request ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: request_id

Required: False
Position: 3
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap](https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap)

