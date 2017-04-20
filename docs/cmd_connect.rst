Connect Commands
=========================

This page contains details on **Connect** commands.

Connect-Rubrik
-------------------------


NAME
    Connect-Rubrik
    
SYNOPSIS
    Connects to Rubrik and retrieves a token value for authentication
    
    
SYNTAX
    Connect-Rubrik [-Server] <String> [[-Username] <String>] [[-Password] <SecureString>] [[-Credential] <Object>] [<CommonParameters>]
    
    
DESCRIPTION
    The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method.
    Rubrik then returns a unique token to represent the user's credentials for subsequent calls.
    Acquire a token before running other Rubrik cmdlets.
    Note that you can pass a username and password or an entire set of credentials.
    

PARAMETERS
    -Server <String>
        The IP or FQDN of any available Rubrik node within the cluster
        
    -Username <String>
        Username with permissions to connect to the Rubrik cluster
        Optionally, use the Credential parameter
        
    -Password <SecureString>
        Password for the Username provided
        Optionally, use the Credential parameter
        
    -Credential <Object>
        Credentials with permission to connect to the Rubrik cluster
        Optionally, use the Username and Password parameters
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Connect-Rubrik -Server 192.168.1.1 -Username admin
    
    This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1.
    The prompt will request a secure password.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
    
    If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Connect-Rubrik -Server 192.168.1.1 -Credential (Get-Credential)
    
    Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Connect-Rubrik -examples".
    For more information, type: "get-help Connect-Rubrik -detailed".
    For technical information, type: "get-help Connect-Rubrik -full".
    For online help, type: "get-help Connect-Rubrik -online"




