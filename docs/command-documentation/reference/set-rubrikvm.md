---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVM
schema: 2.0.0
---

# Set-RubrikVM

## SYNOPSIS
Applies settings on one or more virtual machines known to a Rubrik cluster

## SYNTAX

```
Set-RubrikVM [-id] <String> [[-SnapConsistency] <String>] [[-cloudInstantiationSpec] <Hashtable>]
 [[-MaxNestedSnapshots] <Int32>] [-PauseBackups] [-UseArrayIntegration] [[-Server] <String>] [[-api] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVM 'Server1' | Set-RubrikVM -PauseBackups
```

This will pause backups on any virtual machine named "Server1"

### EXAMPLE 2
```
Get-RubrikVM 'Server1' | Set-RubrikVM -PauseBackups:$false
```

This will unpause backups on any virtual machine named "Server1"

### EXAMPLE 3
```
Get-RubrikVM -SLA Platinum | Set-RubrikVM -SnapConsistency 'CRASH_CONSISTENT' -MaxNestedSnapshots 2 -UseArrayIntegration
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

### -cloudInstantiationSpec
Raw Cloud Instantiation spec

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxNestedSnapshots
The number of existing virtual machine snapshots allowed by Rubrik.
Choices range from 0 - 4 snapshots.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: maxNestedVsphereSnapshots

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PauseBackups
Whether to pause or resume backups/archival for this VM.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: isVmPaused

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseArrayIntegration
User setting to dictate whether to use storage array snaphots for ingest.
This setting only makes sense for VMs where array based ingest is possible.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: isArrayIntegrationEnabled

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
Position: 5
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
Position: 6
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVM](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikVM)

