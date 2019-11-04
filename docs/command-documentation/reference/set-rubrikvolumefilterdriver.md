---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVolumeFilterDriver
schema: 2.0.0
---

# Set-RubrikVolumeFilterDriver

## SYNOPSIS

Used to Install or Uninstall the Rubrik Volume Filter Driver on a registered Windows host.

## SYNTAX

### Install

```text
Set-RubrikVolumeFilterDriver [-hostid <String[]>] [-Install] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Remove

```text
Set-RubrikVolumeFilterDriver [-hostid <String[]>] [-Remove] [-Server <String>] [-api <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikVolumeFilterDriver either installs or uninstalls the Rubrik Volume Filter Driver on a host registered to a Rubrik cluster

## EXAMPLES

### EXAMPLE 1

```text
Set-RubrikVolumeFilterDriver -Id 'Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443' -Install
```

This will install the Volume Filter Driver on the host with an id of Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443

### EXAMPLE 2

```text
Get-RubrikHost -Name server01 -DetailedObject | Set-RubrikVolumeFilterDriver -Remove
```

This will remove the Volume Filter Driver on the host named server01

### EXAMPLE 3

```text
Set-RubrikVolumeFilterDriver -hostId Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443, Host:::a1e1043c-f460-4ac1-a25a-e07b5eh45583 -Install
```

This will install the Volume Filter Driver on the specifed array of host ids

### EXAMPLE 4

```text
Get-RubrikHost -DetailedObject | Where hostVfdDriverState -ne Installed | Set-RubrikVolumeFilterDriver -Install
```

Install Volume Filter Drivers for all hosts where the driver currently is not installed

### EXAMPLE 5

```text
Get-RubrikHost -DetailedObject | Where hostVfdDriverState -eq Installed | Set-RubrikVolumeFilterDriver -Remove
```

Uninstall Volume Filter Drivers for all hosts where the driver currently is not installed

## PARAMETERS

### -hostid

Rubrik's host id value

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: hostids, id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Install

Installs the volume filter driver

```yaml
Type: SwitchParameter
Parameter Sets: Install
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove

Removes the volume filter driver if installed

```yaml
Type: SwitchParameter
Parameter Sets: Remove
Aliases:

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

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVolumeFilterDriver](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVolumeFilterDriver)

