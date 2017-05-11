Disconnect Commands
=========================

This page contains details on **Disconnect** commands.

Disconnect-Rubrik
-------------------------


NAME
    Disconnect-Rubrik
    
SYNOPSIS
    Disconnects from a Rubrik cluster
    
    
SYNTAX
    Disconnect-Rubrik [[-id] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Disconnect-Rubrik function is used to disconnect from a Rubrik cluster.
    This is done by supplying the bearer token and requesting that the session be deleted.
    

PARAMETERS
    -id <String>
        Session id
        
    -Server <String>
        Rubrik server IP or FQDN
        
    -api <String>
        API version
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Disconnect-Rubrik -Confirm:$false
    
    This will close the current session and invalidate the current session token without prompting for confirmation
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>$rubrikConnection = $RubrikConnections[1]
    
    Disconnect-Rubrik
    This will close the second session and invalidate the second session token
    Note: The $rubrikConnections variable holds session details on all established sessions
          The $rubrikConnection variable holds the current, active session
          If you wish to change sessions, simply update the value of $rubrikConnection to another session held within $rubrikConnections
    
    
    
    
REMARKS
    To see the examples, type: "get-help Disconnect-Rubrik -examples".
    For more information, type: "get-help Disconnect-Rubrik -detailed".
    For technical information, type: "get-help Disconnect-Rubrik -full".
    For online help, type: "get-help Disconnect-Rubrik -online"




