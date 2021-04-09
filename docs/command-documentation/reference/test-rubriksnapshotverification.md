---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/test-rubriksnapshotverification
schema: 2.0.0
---

# Test-RubrikSnapshotVerification

## SYNOPSIS
Tests a snapshot or multiple snapshots for consistency

## SYNTAX

```
Test-RubrikSnapshotVerification [-id] <String> [-SnapshotID <String[]>] [-LocationID <String>]
 [-VerifyAfter <DateTime>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Test-RubrikSnapshotVerification cmdlet can be used to validate the fingerprint of a snapshot(s) for consistency and reliablity, returning a csv containing the results

## EXAMPLES

### EXAMPLE 1
```
Test-RubrikSnapshotVerification -id 'VirtualMachine:::111'
```

This will initiate the test for all snapshots on VM with id 111.
A callback uri is returned and an ID in order to track the request

### EXAMPLE 2
```
Get-RubrikVM jaapsvm | Test-RubrikSnapshotVerification
```

This will initiate the test for all snapshots on VM 'jaapsvm', A callback uri is returned and an ID in order to track the request

### EXAMPLE 3
```
Start-RubrikDownload -uri (Test-RubrikSnapshotVerification -id 'VirtualMachine:::111' | Get-RubrikRequest -WaitForCompletion).links[1].href
```

This will initiate the test for all snapshots on VM with id 111.
The cmdlet will then wait for the Snapshot verification to be completed, when this happens the file is stored to the current folder

### EXAMPLE 4
```
Invoke-RestMethod -uri (Test-RubrikSnapshotVerification -id 'VirtualMachine:::111' | Get-RubrikRequest -WaitForCompletion).links[1].href | ConvertFrom-Csv
```

This will initiate the test for all snapshots on VM with id 111.
The cmdlet will then wait for the Snapshot verification to be completed, when this happens the results are converted from csv and displayed in the console

## PARAMETERS

### -id
Object id value

```yaml
Type: String
Parameter Sets: (All)
Aliases: objectId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SnapshotID
Snapshot id value(s)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: snapshotIdsOpt

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocationID
Location id value(s)

```yaml
Type: String
Parameter Sets: (All)
Aliases: locationIdOpt

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifyAfter
The datetime stamp to verify snapshots after

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: shouldVerifyAfterOpt

Required: False
Position: Named
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
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: JaapBrasser

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/test-rubriksnapshotverification](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/test-rubriksnapshotverification)

