---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervmount
schema: 2.0.0
---

# Get-RubrikHyperVMount

## SYNOPSIS
Connects to Rubrik and retrieves details on mounts for a HyperV VM

## SYNTAX

```
Get-RubrikHyperVMount [[-id] <String>] [[-VMID] <String>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikHyperVMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
It is suggested that you first use Get-RubrikHyperVVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikHyperVMount.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikHyperVMount
```

This will return details on all mounted virtual machines.

### EXAMPLE 2
```
Get-RubrikHyperVMount -id '11111111-2222-3333-4444-555555555555'
```

This will return details on mount id "11111111-2222-3333-4444-555555555555".

### EXAMPLE 3
```
Get-RubrikHyperVMount -VMID (Get-RubrikHyperVVM -VM 'Server1').id
```

This will return details for any mounts found using the id value from a virtual machine named "Server1" as a base reference.

### EXAMPLE 4
```
Get-RubrikHyperVMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
```

This will return details for any mounts found using the virtual machine id of 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' as a base reference.

## PARAMETERS

### -id
Rubrik's id of the mount

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -VMID
Filters live mounts by VM ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: vm_id

Required: False
Position: 2
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Mike Preston for community usage
Twitter: @mwpreston
GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervmount](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhypervmount)

