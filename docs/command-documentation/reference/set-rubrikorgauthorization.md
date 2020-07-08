---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikorgauthorization
schema: 2.0.0
---

# Set-RubrikOrgAuthorization

## SYNOPSIS
Assigns a list of authorizations to an organization.

## SYNTAX

```
Set-RubrikOrgAuthorization [-id] <String> [[-OrgID] <String>] [[-UseSLA] <String[]>]
 [[-ManageResource] <String[]>] [[-ManageSLA] <String[]>] [[-Server] <String>] [[-api] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is used to assign authorization to an organization.
Organizations are used to support
Rubrik's multi-tenancy feature.

-UseSLA, -ManageResource, and -ManageSLA can be passed a string, or an array of strings containing the desired IDs.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -UseSLA '12345678-1234-abcd-8910-1234567890ab'
```

Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to use the SLA Domain with ID 12345678-1234-abcd-8910-1234567890ab

### EXAMPLE 2
```
Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
```

Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to manage the VM with ID VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345

### EXAMPLE 3
```
$vms = (Get-RubrikVM -PrimaryClusterId local -Relic:$false | Where-Object { $_.Name -like '*sql*' }).id
```

Set-RubrikOrgAuthorization -ID 'Organization:::01234567-8910-1abc-d435-0abc1234d567' -ManageResource $vms
Authorizes the Organization with ID Organization:::01234567-8910-1abc-d435-0abc1234d567 to manage all VMs with names containing the string 'SQL'

## PARAMETERS

### -id
Principal ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: principals

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OrgID
Organization ID

```yaml
Type: String
Parameter Sets: (All)
Aliases: organization_id

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSLA
Use SLAs.
Must be an SLA ID.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManageResource
Manage Resource.
Can contain any manageable ID.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManageSLA
Manage SLA.
Must be an SLA ID.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 6
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
Position: 7
Default value: $global:RubrikConnection.api
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikorgauthorization](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikorgauthorization)

