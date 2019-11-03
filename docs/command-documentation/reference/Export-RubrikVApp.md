---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Export-RubrikVApp
schema: 2.0.0
---

# Export-RubrikVApp

## SYNOPSIS
Exports a given snapshot for a vCD vApp

## SYNTAX

### Partial
```
Export-RubrikVApp -id <String> -snapshotid <String> -Partial <PSObject> -ExportMode <String>
 [-TargetVAppID <String>] -PowerOn <Boolean> [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Full
```
Export-RubrikVApp -id <String> -snapshotid <String> -ExportMode <String> [-TargetOrgVDCID <String>]
 [-DisableNetwork] [-NoMapping] [-RemoveNetworkDevices] [-NetworkMapping <String>] -PowerOn <Boolean>
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Export-RubrikVApp cmdlet exports a snapshot from a protected vCD vApp.

## EXAMPLES

### EXAMPLE 1
```
Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -PowerOn:$true
```

This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in the same Org VDC

### EXAMPLE 2
```
Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -NoMapping -PowerOn:$true
```

This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in the same Org VDC and remove existing network mappings from VM NICs

### EXAMPLE 3
```
Export-RubrikVApp -id 'VcdVapp:::01234567-8910-1abc-d435-0abc1234d567' -snapshotid '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -ExportMode 'ExportToNewVapp' -TargetOrgVDCID 'VcdOrgVdc:::01234567-8910-1abc-d435-0abc1234d567' -PowerOn:$true
```

This exports the vApp snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to a new vApp in an alternate Org VDC

### EXAMPLE 4
```
$vapp = Get-RubrikVApp -Name 'vApp01' -PrimaryClusterID local
```

$snapshot = Get-RubrikSnapshot -id $vapp.id -Latest
$restorableVms = $vapp.vms
$restorableVms\[0\].PSObject.Properties.Remove('vcenterVm')
$vm = @()
$vm += $restorableVms\[0\]
Export-RubrikVApp -id $vapp.id -snapshotid $snapshot.id -Partial $vm -ExportMode ExportToTargetVapp -PowerOn:$false

This retreives the latest snapshot from the given vApp 'vApp01' and perform a partial export on the first VM in the vApp.
The VM is exported into the existing parent vApp.
Set the ExportMode parameter to 'ExportToNewVapp' parameter to create a new vApp for the partial export.
This is an advanced use case and the user is responsible for parsing the output from Get-RubrikVApp, or gathering data directly from the API.
Syntax of the object passed with the -Partial Parameter is available in the API documentation.

## PARAMETERS

### -id
Rubrik id of the vApp to export

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -snapshotid
Rubrik snapshot id of the vApp to export

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
Perform a Partial vApp restore.
Default operation is a Full vApp restore, unless this parameter is specified.

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

### -ExportMode
Specifies whether export should use the existing vApp or create a new vApp.
Valid values are ExportToNewVapp or ExportToTargetVapp

```yaml
Type: String
Parameter Sets: (All)
Aliases: export_mode

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetVAppID
ID of target vApp for Partial vApp Export.
By default the VM(s) will be exported to their existing vApp.

```yaml
Type: String
Parameter Sets: Partial
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetOrgVDCID
ID of target Org VDC for Full vApp Export.
By default the VM(s) will be exported to their existing Org VDC.
/vcd/hierarchy API calls can be used to determine Org VDC IDs.

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

### -DisableNetwork
Disable NICs upon restoration.
The NIC(s) will be disabled, but remain mapped to their existing network.

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
Remove network mapping upon restoration.
The NIC(s) will not be connected to any existing networks.

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
Written by Matt Elliott for community usage
Twitter: @NetworkBrouhaha
GitHub: shamsway

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Export-RubrikVApp](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Export-RubrikVApp)

