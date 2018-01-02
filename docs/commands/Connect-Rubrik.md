---
external help file: Rubrik-help.xml
Module Name: Rubrik
online version: https://github.com/rubrikinc/PowerShell-Module
schema: 2.0.0
---

# Connect-Rubrik

## SYNOPSIS
Connects to Rubrik and retrieves a token value for authentication

## SYNTAX

```
Connect-Rubrik [-Server] <String> [[-Username] <String>] [[-Password] <SecureString>] [[-Credential] <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method.
Rubrik then returns a unique token to represent the user's credentials for subsequent calls.
Acquire a token before running other Rubrik cmdlets.
Note that you can pass a username and password or an entire set of credentials.

## EXAMPLES

### EXAMPLE 1
```
Connect-Rubrik -Server 192.168.1.1 -Username admin
```

This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1.
The prompt will request a secure password.

### EXAMPLE 2
```
Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
```

If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.

### EXAMPLE 3
```
Connect-Rubrik -Server 192.168.1.1 -Credential (Get-Credential)
```

Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.

## PARAMETERS

### -Server
The IP or FQDN of any available Rubrik node within the cluster

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Username with permissions to connect to the Rubrik cluster
Optionally, use the Credential parameter

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

### -Password
Password for the Username provided
Optionally, use the Credential parameter

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credentials with permission to connect to the Rubrik cluster
Optionally, use the Username and Password parameters

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Written by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl

## RELATED LINKS

[https://github.com/rubrikinc/PowerShell-Module](https://github.com/rubrikinc/PowerShell-Module)

