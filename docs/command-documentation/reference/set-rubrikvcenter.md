---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvcenter
schema: 2.0.0
---

# Set-RubrikVCenter

## SYNOPSIS
Connects to Rubrik and modifies an existing vCenter connection

## SYNTAX

### UserPassword
```
Set-RubrikVCenter -id <String> -Hostname <String> -Username <String> -Password <SecureString>
 [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Credential
```
Set-RubrikVCenter -id <String> -Hostname <String> -Credential <Object> [-Server <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Set-RubrikVCenter cmdlet will modifies an existing vCenter connection on the system.
This does require authentication.

## EXAMPLES

### EXAMPLE 1
```
Set-RubrikVCenter -hostname "test-vcenter.domain.com"
```

This will return the running cluster settings on the Rubrik cluster.

## PARAMETERS

### -id
vCenter ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Hostname
vCenter Hostname (FQDN)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
Username with permissions to connect to the vCenter
Optionally, use the Credential parameter

```yaml
Type: String
Parameter Sets: UserPassword
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Password
Password for the Username provided
Optionally, use the Credential parameter

```yaml
Type: SecureString
Parameter Sets: UserPassword
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credentials with permission to connect to the vCenter
Optionally, use the Username and Password parameters

```yaml
Type: Object
Parameter Sets: Credential
Aliases:

Required: True
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
Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvcenter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikvcenter)

