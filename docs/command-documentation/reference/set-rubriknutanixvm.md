---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikNutanixVM
schema: 2.0.0
---

# Set-RubrikNutanixVM

## SYNOPSIS
Applies settings on one or more virtual machines known to a Rubrik cluster

## SYNTAX

```
Set-RubrikNutanixVM [-id] <String> [[-SnapConsistency] <String>] [-PauseBackups] [[-Server] <String>]
 [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikNutanixVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikNutanixVM 'Server1' | Set-RubrikNutanixVM -PauseBackups
```

This will pause backups on any virtual machine named "Server1"

### EXAMPLE 2
```
Get-RubrikNutanixVM 'Server1' | Set-RubrikNutanixVM -PauseBackups:$false
```

This will unpause backups on any virtual machine named "Server1"

### EXAMPLE 3
```
Get-RubrikNutanixVM -SLA Platinum | Set-RubrikNutanixVM -SnapConsistency 'CRASH_CONSISTENT' -MaxNestedSnapshots 2 -UseArrayIntegration
```

This will find all virtual machines in the Platinum SLA Domain and set their snapshot consistency to crash consistent (no application quiescence)
while also limiting the number of active hypervisor snapshots to 2 and enable storage array (SAN) snapshots for ingest

## PARAMETERS

### -id
Virtual machine ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SnapConsistency
Consistency level mandated for this VM

```yaml
Type: String
Parameter Sets: (All)
Aliases: snapshotConsistencyMandate

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PauseBackups
Whether to pause or resume backups/archival for this VM.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: isPaused

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
Position: 3
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
Position: 4
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
Written by Mike Fal for community usage
Twitter: @Mike_Fal
GitHub: MikeFal

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikNutanixVM](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikNutanixVM)

