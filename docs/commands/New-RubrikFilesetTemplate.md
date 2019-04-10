---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: http://rubrikinc.github.io/rubrik-sdk-for-powershell/
schema: 2.0.0
---

# New-RubrikFilesetTemplate

## SYNOPSIS
Creates a new fileset template.

## SYNTAX

### OSType
```
New-RubrikFilesetTemplate [-Name <String>] [-AllowBackupNetworkMounts]
 [-AllowBackupHiddenFoldersInNetworkMounts] [-UseWindowsVSS] [-Includes <String[]>] [-Excludes <String[]>]
 [-Exceptions <String[]>] [-OperatingSystemType <String>] [-PreBackupScript <String>]
 [-PostBackupScript <String>] [-BackupScriptTimeout <Int32>] [-BackupScriptErrorHandling <String>]
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ShareType
```
New-RubrikFilesetTemplate [-Name <String>] [-AllowBackupNetworkMounts]
 [-AllowBackupHiddenFoldersInNetworkMounts] [-UseWindowsVSS] [-Includes <String[]>] [-Excludes <String[]>]
 [-Exceptions <String[]>] [-ShareType <String>] [-PreBackupScript <String>] [-PostBackupScript <String>]
 [-BackupScriptTimeout <Int32>] [-BackupScriptErrorHandling <String>] [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new fileset template for Linux hosts, Windows hosts, and NAS shares.
This must be
done before creating a new fileset, as filesets are defined by the templates.
Some caveats that
are defined by the Rubrik GUI but not applied here:
 - If creating a Windows Fileset Template, you should declare UseWindowsVSS equal to true
 - If you define a pre or post backup script, you need to define error handling
 - If you define a pre or post backup script, you should definte the backup script timeout value to 14400

## EXAMPLES

### EXAMPLE 1
```
New-RubrikFilesetTemplate -Name 'FOO' -UseWindowsVSS -OperatingSystemType 'Windows' -Includes 'C:\*.mp3','C:\*.csv'
```

Create a Windows Fileset Template to backup .mp3 and .csv on the C:\.

### EXAMPLE 2
```
New-RubrikFilesetTemplate -Name 'BAR' -ShareType 'SMB' -Includes '*' -Excludes '*.pdf'
```

Create a new NAS FilesetTemplate named BAR to backup a NAS SMB share, backing up everything byt excluding all .pdf files.

## PARAMETERS

### -Name
Name of fileset template

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowBackupNetworkMounts
Boolean - Allow Backup Network Mounts

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowBackupHiddenFoldersInNetworkMounts
Boolean - Allow Backup Hidden Folders in Network Mounts

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseWindowsVSS
Enable Windows VSS

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Includes
Include naming patterns

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Excludes
Exclude naming patterns

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exceptions
Exceptions for exclude naming patterns

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperatingSystemType
Operating System Type

```yaml
Type: String
Parameter Sets: OSType
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShareType
Share Type

```yaml
Type: String
Parameter Sets: ShareType
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreBackupScript
Path to pre-backup script

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostBackupScript
Path to post-backup script

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupScriptTimeout
Backup script timeout

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupScriptErrorHandling
Error handling for backup script

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
Written by Mike Fal
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[http://rubrikinc.github.io/rubrik-sdk-for-powershell/](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)

