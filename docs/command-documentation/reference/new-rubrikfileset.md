---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikfileset
schema: 2.0.0
---

# New-RubrikFileset

## SYNOPSIS
Creates a fileset by assigning a fileset template to a host or NAS share

## SYNTAX

### NAS
```
New-RubrikFileset -TemplateID <String> -ShareID <String> [-DirectArchive] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### Host
```
New-RubrikFileset -TemplateID <String> -HostID <String> [-Server <String>] [-api <String>] [<CommonParameters>]
```

## DESCRIPTION
New-RubrikFileset takes a Fileset Template, along with a host id or NAS Share and creates a fileset by assigning the template
to the host or NAS share.
This cmdlet simply assigns the template to the host but does not protect it.
This cmdlet is commonly
followed up with Protect-RubrikFileset which will assign an SLA domain to the fileset and perform subsequent backups.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikFileset -TemplateID 'FilesetTemplate:::1111-1111-1111-1111' -HostID 'Host::::2222-2222-2222-2222'
```

Creates a new fileset on the specified host, using the selected template.

### EXAMPLE 2
```
New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id
```

Creates a new fileset for the BAR NAS, using the FOO template.

### EXAMPLE 3
```
New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id -DirectArchive
```

Creates a new fileset for the BAR NAS, using the FOO template.
Enables the NAS Direct Archive functionality on the share.

## PARAMETERS

### -TemplateID
Fileset Template ID to use for the new fileset

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostID
HostID - Used for Windows or Linux Filesets

```yaml
Type: String
Parameter Sets: Host
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShareID
ShareID - used for NAS shares

```yaml
Type: String
Parameter Sets: NAS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectArchive
DirectArchive - used to specify if data should be directly sent to archive (bypassing Rubrik Cluster)

```yaml
Type: SwitchParameter
Parameter Sets: NAS
Aliases: isPassThrough

Required: False
Position: Named
Default value: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikfileset](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikfileset)

