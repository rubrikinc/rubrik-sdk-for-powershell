---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/register-rubrikbackupservice
schema: 2.0.0
---

# Register-RubrikBackupService

## SYNOPSIS
Register the Rubrik Backup Service

## SYNTAX

```
Register-RubrikBackupService [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
```

## DESCRIPTION
Register the Rubrik Backup Service for the specified VM

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikVM -Name "demo-win01" | Register-RubrikBackupService -Verbose
```

Get the details of VMware VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster

### EXAMPLE 2
```
Get-RubrikNutanixVM -Name "demo-ahv01" | Register-RubrikBackupService -Verbose
```

Get the details of Nutanix VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster

### EXAMPLE 3
```
Get-RubrikHyperVVM -Name "demo-hyperv01" | Register-RubrikBackupService -Verbose
```

Get the details of Hyper-V VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster

### EXAMPLE 4
```
Register-RubrikBackupService -VMid VirtualMachine:::2af8fe5f-5b64-44dd-a9e0-ec063753b823-vm-37558
```

Register the Rubrik Backup Service installed on this VM with the Rubrik cluster by specifying the VM id

## PARAMETERS

### -id
ID of the VM which agent needs to be registered

```yaml
Type: String
Parameter Sets: (All)
Aliases: VMid

Required: True
Position: 1
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
Position: 2
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
Position: 3
Default value: $global:RubrikConnection.api
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Pierre-Fran §ois Guglielmi
Twitter: @pfguglielmi
GitHub: pfguglielmi

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/register-rubrikbackupservice](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/register-rubrikbackupservice)

