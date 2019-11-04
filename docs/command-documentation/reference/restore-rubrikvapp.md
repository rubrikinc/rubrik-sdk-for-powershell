---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Restore-RubrikVApp
schema: 2.0.0
---

# Restore-RubrikVApp

## SYNOPSIS

Restores a given snapshot for a vCD vApp

## SYNTAX

### Partial

```text
Restore-RubrikVApp -id <String> -Partial <PSObject> -PowerOn <Boolean> [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Full

```text
Restore-RubrikVApp -id <String> [-DisableNetwork] [-NoMapping] [-RemoveNetworkDevices]
 [-NetworkMapping <String>] -PowerOn <Boolean> [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Restore-RubrikVApp cmdlet is used to restore a snapshot from a protected vCD vApp. The existing vApp will be marked as 'deprecated' if it exists at the time of restore.

## EXAMPLES

### EXAMPLE 1

```text
Restore-RubrikVApp -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -PowerOn:$true
```

This restores the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b

### EXAMPLE 2

```text
(Get-RubrikVApp 'vApp01' -PrimaryClusterID local | Get-RubrikSnapshot -Latest).id | Restore-RubrikVApp -PowerOn:$true
```

This retreives the latest snapshot from the given vApp 'vApp01' and restores it

### EXAMPLE 3

```text
$id = (Get-RubrikVApp -Name "vApp01" -PrimaryClusterID local | Get-RubrikSnapshot -Latest ).id
```

$recoveropts = Get-RubrikVAppRecoverOptions -Id $id $restorableVms = $recoveropts.restorableVms $vm = @\(\) $vm += $restorableVms\[0\] Restore-RubrikVApp -id $id -Partial $vm -PowerOn:$false This retreives the latest snapshot from the given vApp 'vApp01' and performs a partial restore on the first VM in the vApp. This is an advanced use case and the user is responsible for parsing the output from Get-RubrikVAppRecoverOptions. Syntax of the object passed with the -Partial Parameter must match the format of the object returned from \(Get-RubrikVAppRecoverOptions\).restorableVms

## PARAMETERS

### -id

Rubrik id of the vApp snapshot to restore

```yaml
Type: String
Parameter Sets: (All)
Aliases: snapshot_id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Partial

Perform a Partial vApp restore. Default operation is a Full vApp restore, unless this parameter is specified.

```yaml
Type: PSObject
Parameter Sets: Partial
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableNetwork

Disable NICs upon restoration. The NIC\(s\) will be disabled, but remain mapped to their existing network.

```yaml
Type: SwitchParameter
Parameter Sets: Full
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoMapping

Remove network mapping upon restoration. The NIC\(s\) will not be connected to any existing networks.

```yaml
Type: SwitchParameter
Parameter Sets: Full
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveNetworkDevices

Remove network interfaces from the restored vApp virtual machines.

```yaml
Type: SwitchParameter
Parameter Sets: Full
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkMapping

Map all vApp virtual machine NICs to specified network.

```yaml
Type: String
Parameter Sets: Full
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerOn

Power on vApp after restoration.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
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

Written by Matt Elliott for community usage Twitter: @NetworkBrouhaha GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Restore-RubrikVApp](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Restore-RubrikVApp)

