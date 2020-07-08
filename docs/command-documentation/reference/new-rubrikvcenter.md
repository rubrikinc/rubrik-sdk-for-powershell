---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvcenter
schema: 2.0.0
---

# New-RubrikVCenter

## SYNOPSIS
Connects to Rubrik and creates new vCenter connection

## SYNTAX

### UserPassword
```
New-RubrikVCenter -Hostname <String> -Username <String> -Password <SecureString> [-Server <String>]
 [-id <String>] [-api <String>] [<CommonParameters>]
```

### Credential
```
New-RubrikVCenter -Hostname <String> -Credential <Object> [-Server <String>] [-id <String>] [-api <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The New-RubrikVCenter cmdlet will  creates new vCenter connection on the system.
This does require authentication.

## EXAMPLES

### EXAMPLE 1
```
New-RubrikVCenter -hostname "test-vcenter.domain.com"
```

This will creates new vCenter connection to "test-vcenter.domain.com" on the current Rubrik cluster

## PARAMETERS

### -Hostname
Hostname (FQDN) of your vCenter Server

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage

## RELATED LINKS

[https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvcenter](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikvcenter)

