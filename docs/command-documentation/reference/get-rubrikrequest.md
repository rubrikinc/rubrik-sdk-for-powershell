---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikrequest
schema: 2.0.0
---

# Get-RubrikRequest

## SYNOPSIS
Connects to Rubrik and retrieves details on an async request

## SYNTAX

### Entry
```
Get-RubrikRequest -id <String> -Type <String> [-WaitForCompletion] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

### Pipeline
```
Get-RubrikRequest -Request <PSObject> [-WaitForCompletion] [-Server <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
This is helpful for tracking the state (success, failure, running, etc.) of a request.

## EXAMPLES

### EXAMPLE 1
```
Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
```

Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"

### EXAMPLE 2
```
Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
```

Will wait for the specified async request to report a 'SUCCESS' or 'FAILED' status before returning details

### EXAMPLE 3
```
Get-RubrikVM jbrasser-lin | Get-RubrikSnapshot -Latest | New-RubrikMount -MountName 'SuperCoolVM' | Get-RubrikRequest -WaitForCompletion -Verbose
```

Will take the latest Snapshot of jbrasser-lin and create a live mount of this Virtual Machine, Get-RubrikRequest will poll the cluster until the VM is available while displaying Verbose information.

### EXAMPLE 4
```
Update-RubrikVCenter vCenter:::111 | Get-RubrikRequest -WaitForCompletion
```

Updates Rubrik vCenter and waits for completion of the request

## PARAMETERS

### -id
ID of an asynchronous request

```yaml
Type: String
Parameter Sets: Entry
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of request

```yaml
Type: String
Parameter Sets: Entry
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Request
Request

```yaml
Type: PSObject
Parameter Sets: Pipeline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WaitForCompletion
Wait for Request to Complete

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikrequest](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikrequest)

