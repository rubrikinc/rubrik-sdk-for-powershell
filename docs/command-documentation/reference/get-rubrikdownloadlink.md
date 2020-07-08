---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdownloadlink
schema: 2.0.0
---

# Get-RubrikDownloadLink

## SYNOPSIS
Create a download link based on a snapshot object and a source dirs path

## SYNTAX

```
Get-RubrikDownloadLink [-SLAObject] <PSObject> [-sourceDirs <String[]>] [-Server <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikDownloadLink cmdlet creates a download link based on snapshot object paired with a sourceDirs path

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Get-RubrikDownloadLink -Verbose
```

Will create a download link for the complete set of data from the jaap.testhost.us hostname while displaying verbose information

### EXAMPLE 2
```
Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Get-RubrikDownloadLink -sourceDirs '\test'
```

Will only create a download link for files and folders located in the root folder 'test' of the selected fileset

## PARAMETERS

### -SLAObject
The SLA Object that should be downloaded

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -sourceDirs
Which folders and files should be included, defaults to all "/"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('/')
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdownloadlink](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikdownloadlink)

