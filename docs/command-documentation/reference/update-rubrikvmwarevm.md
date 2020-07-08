---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubrikvmwarevm
schema: 2.0.0
---

# Update-RubrikVMwareVM

## SYNOPSIS
Connects to Rubrik to refresh the metadata for the specified VMware VM

## SYNTAX

```
Update-RubrikVMwareVM [-vcenterId] <String> [-vmMoid] <String> [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Update-RubrikVMwareVM cmdlet will refresh the specified VMware VM metadata known to the connected Rubrik cluster.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVM -Name 'myvm.domain.local' | Update-RubrikVMwareVM
```

This will refresh the VMware VM metadata on the currently connected Rubrik cluster

### EXAMPLE 2
```
Update-RubrikVMwareVM -Id vCenter:::1226ff04-6100-454f-905b-5df817b6981a -moid vm-100
```

This will refresh the VMware VM metadata, for the VM and vcCenter specified, on the currently connected Rubrik cluster

### EXAMPLE 3
```
Import-Csv .\RefreshVM.csv | Update-RubrikVMwareVM -Verbose
```

This will refresh the VMware VM metadata, for the VM and vcCenter specified in the csv file, on the currently connected Rubrik cluster while displaying verbose information.
Please note that the .csv file should contain the id and moid fields.

## PARAMETERS

### -vcenterId
vCenter id value from the Rubrik Cluster

```yaml
Type: String
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -vmMoid
VMware VM id value from the Rubrik Cluster

```yaml
Type: String
Parameter Sets: (All)
Aliases: moid

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Written by Pierre-Fran §ois Guglielmi for community usage
Twitter: @pfguglielmi
GitHub: pfguglielmi

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubrikvmwarevm](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/update-rubrikvmwarevm)

