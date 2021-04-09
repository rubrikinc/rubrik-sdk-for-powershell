---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikldap
schema: 2.0.0
---

# New-RubrikLDAP

## SYNOPSIS
Connects to Rubrik and sets Rubrik cluster settings

## SYNTAX

### UserPassword (Default)
```
New-RubrikLDAP -Name <String> [-DynamicDNSName <String>] [-baseDn <String>] [-AuthServers <Array>]
 [-BindUserName] <String> [-BindUserPassword] <SecureString> [-Server <String>] [-id <String>] [-api <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Credential
```
New-RubrikLDAP -Name <String> -BindCredential <Object> [-DynamicDNSName <String>] [-baseDn <String>]
 [-AuthServers <Array>] [-Server <String>] [-id <String>] [-api <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikLDAP cmdlet will set the cluster settings on the system.
This does require authentication.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikLDAP -Name "Test LDAP Settings" -baseDn "DC=domain,DC=local" -authServers "192.168.1.8"
```

This will create LDAP settings on the Rubrik cluster defined by Connect-Rubrik function

### EXAMPLE 2
```
$credential = Get-Credential
```

New-RubrikLDAP -Name "rubrik.lab" -DynamicDNSName "ad1.test.lab" -baseDn "DC=rubrik,DC=lab" -BindCredential $Credential -Verbose

This will create LDAP settings using the credentials object provided as a parameter

### EXAMPLE 3
```
$SecPw = Read-Host -AsSecureString
```

New-RubrikLDAP -Name "rubrik.lab" -DynamicDNSName "ad1.test.lab" -baseDn "DC=rubrik,DC=lab" -BindUserName jaapjaap -BindUserPassword $SecPw -Verbose

This will create LDAP settings using the user name and password provided as parameters

## PARAMETERS

### -Name
Human friendly name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindCredential
Bind credentials with permission to connect to the LDAP server
Optionally, use the BindUserName and BindUserPassword parameters

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

### -DynamicDNSName
Dynamic DNS name for locating authentication servers.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -baseDn
The path to the directory where searches for users begin.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthServers
An ordered list of authentication servers.
Servers on this list have priority over servers discovered using dynamic DNS.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindUserName
Bind username with permissions to connect to the LDAP server
Optionally, use the BindCredential parameter

```yaml
Type: String
Parameter Sets: UserPassword
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindUserPassword
Password for the Username provided
Optionally, use the Credential parameter

```yaml
Type: SecureString
Parameter Sets: UserPassword
Aliases:

Required: True
Position: 3
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

### -id
ID of the Rubrik cluster or me for self

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikldap](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikldap)

