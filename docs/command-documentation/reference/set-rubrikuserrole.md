---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: >-
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikUserRole
schema: 2.0.0
---

# Set-RubrikUserRole

## SYNOPSIS

Updates an existing users role

## SYNTAX

### ReadOnlyAdmin

```text
Set-RubrikUserRole -Id <String[]> [-ReadOnlyAdmin] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### EndUserRemove

```text
Set-RubrikUserRole -Id <String[]> [-EndUser] [-Remove] [-EventObjects <String[]>]
 [-RestoreWithoutDownloadObjects <String[]>] [-RestoreWithOverwriteObjects <String[]>]
 [-OnDemandSnapshotObjects <String[]>] [-ReportObjects <String[]>] [-RestoreObjects <String[]>]
 [-InfrastructureObjects <String[]>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### EndUserAdd

```text
Set-RubrikUserRole -Id <String[]> [-EndUser] [-Add] [-EventObjects <String[]>]
 [-RestoreWithoutDownloadObjects <String[]>] [-RestoreWithOverwriteObjects <String[]>]
 [-OnDemandSnapshotObjects <String[]>] [-ReportObjects <String[]>] [-RestoreObjects <String[]>]
 [-InfrastructureObjects <String[]>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### NoAccess

```text
Set-RubrikUserRole -Id <String[]> [-NoAccess] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Admin

```text
Set-RubrikUserRole -Id <String[]> [-Admin] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The Set-RubrikUserRole cmdlet is used modify a users role and authorizations to objects within the Rubrik cluster

## EXAMPLES

### EXAMPLE 1

```text
Set-RubrikUserRole -id 'User:::1111-2222-3333' -Admin
```

This will set the specifed users role to admin

### EXAMPLE 2

```text
Set-RubrikUserRole -id 'User:::1111-2222-3333' -ReadOnlyAdmin
```

This will set the specifed users role to read only admin. Valid on Rubrik CDM 5.0 and later

### EXAMPLE 3

```text
Set-RubrikUserRole -id 'User:::1111-2222-3333' -EndUser -Add -RestoreObjects 'VirtualMachine:::1111-222'
```

This will set the specifed users role to end user, granting access to restore the specified virtual machine

### EXAMPLE 4

```text
Set-RubrikUserRole -id 'User:::1111-2222-3333' -EndUser -Remove -RestoreObjects 'VirtualMachine:::1111-222'
```

This will set the specifed users role to end user, removing access to restore the specified virtual machine

### EXAMPLE 5

```text
Set-RubrikUserRole -id 'User:::1111-2222-3333' -NoAccess
```

This will remove all permissions on the Rubrik cluster for the specified user.

## PARAMETERS

### -Id

User ID

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: principals

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Admin

Sets users role to Admin

```yaml
Type: SwitchParameter
Parameter Sets: Admin
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndUser

Sets users role to End User

```yaml
Type: SwitchParameter
Parameter Sets: EndUserRemove, EndUserAdd
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoAccess

Sets users role to No Access \(Removes all access from user\)

```yaml
Type: SwitchParameter
Parameter Sets: NoAccess
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReadOnlyAdmin

Sets users role to No Access \(Removes all access from user\)

```yaml
Type: SwitchParameter
Parameter Sets: ReadOnlyAdmin
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Add

Specifies -Privileges should be added to the users authorizations

```yaml
Type: SwitchParameter
Parameter Sets: EndUserAdd
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove

Specifies -Privileges should be removed from the users authorizations

```yaml
Type: SwitchParameter
Parameter Sets: EndUserRemove
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventObjects

Event Objects to grant or revoke access to

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: viewEvent

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestoreWithoutDownloadObjects

Objects which can be restored, with file download disabled

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: restoreWithoutDownload

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestoreWithOverwriteObjects

Objects which can be restored, overwriting original

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: destructiveRestore

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnDemandSnapshotObjects

Objects allowing On-Demand Snapshots

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: onDemandSnapshot

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportObjects

Report objects

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: viewReport

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestoreObjects

Objects which can be restored

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: restore

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -InfrastructureObjects

Infrastructure Objects allowing provisioning of restores/live mounts

```yaml
Type: String[]
Parameter Sets: EndUserRemove, EndUserAdd
Aliases: provisionOnInfra

Required: False
Position: Named
Default value: @()
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

Written by Mike Preston for community usage Twitter: @mwpreston GitHub: mwpreston

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikUserRole](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Set-RubrikUserRole)

