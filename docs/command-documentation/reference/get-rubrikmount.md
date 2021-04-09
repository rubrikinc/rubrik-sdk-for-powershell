---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmount
schema: 2.0.0
---

# Get-RubrikMount

## SYNOPSIS
Connects to Rubrik and retrieves details on mounts for a VM

## SYNTAX

```
Get-RubrikMount [[-id] <String>] [[-VMID] <String>] [-DetailedObject] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
Due to the nature of names not being unique
Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikMount.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikMount
```

This will return details on all mounted virtual machines.

### EXAMPLE 2
```
Get-RubrikMount -DetailedObject
```

This will retrieve all mounted virtual machines with additional details

### EXAMPLE 3
```
Get-RubrikMount -id '11111111-2222-3333-4444-555555555555'
```

This will return details on mount id "11111111-2222-3333-4444-555555555555".

### EXAMPLE 4
```
Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id
```

This will return details for any mounts found using the id value from a virtual machine named "Server1" as a base reference.

### EXAMPLE 5
```
Get-RubrikMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
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

### -DetailedObject
DetailedObject will retrieved the detailed VM Mount object, the default behavior of the API is to only retrieve a subset of the full VM Mount object unless we query directly by ID.
Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.

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
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmount](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikmount)

