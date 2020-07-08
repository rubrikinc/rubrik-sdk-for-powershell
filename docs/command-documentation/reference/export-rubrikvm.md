---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvm
schema: 2.0.0
---

# Export-RubrikVM

## SYNOPSIS
Exports a given snapshot for a VMware VM

## SYNTAX

```
Export-RubrikVM [-id] <String> [-DatastoreId] <String> [-HostID] <String> [[-VMName] <String>]
 [-DisableNetwork] [-RemoveNetworkDevices] [-KeepMACAddresses] [-UnregisterVM] [-PowerOn] [-RecoverTags]
 [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Export-RubrikVM cmdlet is used to restore a snapshot from a protected VM, copying all data to a given datastore and running the VM in an existing vSphere environment.

## EXAMPLES

### EXAMPLE 1
```
Export-RubrikVM -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
```

This will mount the snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to the specified host and datastore

### EXAMPLE 2
```
Get-RubrikVM 'server01' -PrimaryClusterID local | Get-RubrikSnapshot | Sort-Object -Property Date -Descending | Select -First 1 | Export-RubrikVM -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
```

This will retreive the latest snapshot from the given VM 'server01' and export to the specified host and datastore.

## PARAMETERS

### -id
Rubrik id of the snapshot to export

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

### -DatastoreId
Rubrik id of the vSphere datastore to store exported VM.
(Use "Invoke-RubrikRESTCall -Endpoint 'vmware/datastore' -Method 'GET' -api 'internal'" to retrieve a list of available VMware datastores)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostID
ID of host for the export to use (Use "Invoke-RubrikRESTCall -Endpoint 'vmware/host' -Method 'GET' -api '1'" to retrieve a list of available VMware hosts.)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMName
Name of the exported VM

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableNetwork
Whether the network should be disabled upon restoration.
This should be set true to avoid ip conflict if source VM still exists.

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

### -RemoveNetworkDevices
Whether to remove network interfaces from the restored virtual machine.
Default is false.

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

### -KeepMACAddresses
Whether to assign MAC addresses from source virtual machine to exported virtual machine.
Default is false.

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

### -UnregisterVM
Whether the newly restored virtual machine is unregistered from vCenter.
Default is false.

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

### -PowerOn
Whether the VM should be powered on after restoration.
Default is true.

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

### -RecoverTags
Whether to recover vSphere tags

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: shouldRecoverTags

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
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvm](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/export-rubrikvm)

