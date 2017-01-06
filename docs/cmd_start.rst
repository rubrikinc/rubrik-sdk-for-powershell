Start Commands
=========================

This page contains details on **Start** commands.

Start-RubrikVM
-------------------------


NAME
    Start-RubrikVM
    
SYNOPSIS
    Powers on a live mounted virtual machine within a connected Rubrik vCenter.
    
    
SYNTAX
    Start-RubrikVM [-VM] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The Stop-RubrikVM cmdlet is used to send a power on request to any virtual machine visible to a Rubrik 
    cluster.
    

PARAMETERS
    -VM <String>
        Virtual machine name
        
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
    
    PS C:\>Start-RubrikVM -VM 'Server1'
    
    This will send a power on request to Server1
    
    
    
    
REMARKS
    To see the examples, type: "get-help Start-RubrikVM -examples".
    For more information, type: "get-help Start-RubrikVM -detailed".
    For technical information, type: "get-help Start-RubrikVM -full".
    For online help, type: "get-help Start-RubrikVM -online"



