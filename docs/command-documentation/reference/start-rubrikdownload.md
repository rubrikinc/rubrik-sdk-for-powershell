---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikdownload
schema: 2.0.0
---

# Start-RubrikDownload

## SYNOPSIS
Download a file from the Rubrik cluster

## SYNTAX

### Uri (Default)
```
Start-RubrikDownload [<CommonParameters>]
```

### uri
```
Start-RubrikDownload [-Uri] <String> [[-Path] <String>] [[-sourceDirs] <String[]>] [<CommonParameters>]
```

### pipeline
```
Start-RubrikDownload [-SLAObject] <PSObject> [[-Path] <String>] [[-sourceDirs] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
The Start-RubrikDownload cmdlet will download files from the Rubrik cluster, it can either take a uri or a snapshot object paired with a sourceDirs path.
Returns the file object

## EXAMPLES

### EXAMPLE 1
```
Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip
```

Will download the specified file from the Rubrik cluster to the current folder

### EXAMPLE 2
```
Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path /Temp
```

Will download the specified file from the Rubrik cluster to the 'Temp' folder

### EXAMPLE 3
```
Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "/Temp/MyImportedFileSet.zip"
```

Will download the specified file from the Rubrik cluster to the 'Temp' folder with the 'MyImportedFileSet.zip' filename

### EXAMPLE 4
```
Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Start-RubrikDownload -Verbose
```

Will download the complete set of data from the jaap.testhost.us hostname while displaying verbose information

### EXAMPLE 5
```
Get-RubrikFileSet -HostName jaap.testhost.us | Get-RubrikSnapshot -Latest | Start-RubrikDownload -sourceDirs '\test'
```

Will only download files and folders located in the root folder 'test' of the selected fileset

## PARAMETERS

### -Uri
The URI to download

```yaml
Type: String
Parameter Sets: uri
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SLAObject
The SLA Object that should be downloaded

```yaml
Type: PSObject
Parameter Sets: pipeline
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
The path where the folder where the zip files should be downloaded to, if no file extension is specified the file will downloaded with default filename

```yaml
Type: String
Parameter Sets: uri, pipeline
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -sourceDirs
Which folders and files should be included, defaults to all "/"

```yaml
Type: String[]
Parameter Sets: uri, pipeline
Aliases:

Required: False
Position: 2
Default value: @('/')
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikdownload](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/start-rubrikdownload)

