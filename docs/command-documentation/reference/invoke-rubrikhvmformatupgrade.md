---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikhvmformatupgrade
schema: 2.0.0
---

# Invoke-RubrikHvmFormatUpgrade

## SYNOPSIS
Connects to Rubrik and sets the forceFullSpec flag of any number of Hyper-V Virtual Machines that needs upgrade.
It sets the VirtualDiskInfos to empty(default)
so that all the disks present within the VM gets set up for a full.

## SYNTAX

```
Invoke-RubrikHvmFormatUpgrade [-VMList] <String[]> [-notPrintingDetail] [[-body] <String>] [[-Server] <String>]
 [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-RubrikHvmFormatUpgrade cmdlet will update the forceFullSpec of a given list of Hyper-V Virtual Machines.
If these Hyper-V Virtual Machines are using the SMB backup method, their forceFull flag will be set, and they will be upgraded to use the fast VHDX method in the next backup.

## EXAMPLES

### EXAMPLE 1
```
Invoke-RubrikHvmFormatUpgrade -VMList HypervVirtualMachine:::e0a04776-ab8e-45d4-8501-8da658221d74, HypervVirtualMachine:::9136a7ef-4ad2-4bb9-bf28-961fb74d4322
```

This will set the forceFullspec of the given Hyper-V Virtual Machines to default, which will force a full.

### EXAMPLE 2
```
Get-RubrikVVM -hostname ad.flammi.home | Invoke-RubrikHvmFormatUpgrade
```

This will set the forceFullSpec of the Hyper-V Virtual Machine to default belonging to the specified hostname, which will force a full

## PARAMETERS

### -VMList
HypervVirtualMachine ID

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -notPrintingDetail
Print details during confirmation

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

### -body
{{ Fill body Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
Written by Abhinav Prakash for community usage
github: ab-prakash

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikhvmformatupgrade](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikhvmformatupgrade)

