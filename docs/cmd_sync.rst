Sync Commands
=========================

This page contains details on **Sync** commands.

Sync-RubrikTag
-------------------------


NAME
    Sync-RubrikTag
    
SYNOPSIS
    Connects to Rubrik and creates a vSphere tag for each SLA Domain
    
    
SYNTAX
    Sync-RubrikTag [-Category] <String> [-Server <String>] [-api <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Sync-RubrikTag cmdlet will query Rubrik for all of the existing SLA Domains, and then create a tag for each one
    

PARAMETERS
    -Category <String>
        The vSphere Category name for the Rubrik SLA Tags
        
    -Server <String>
        Rubrik server IP or FQDN
        
    -api <String>
        API version
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Sync-RubrikTag -vCenter 'vcenter1.demo' -Category 'Rubrik'
    
    This will validate or create a vSphere Category named Rubrik along with a Tag for each SLA Domain found in Rubrik
    
    
    
    
REMARKS
    To see the examples, type: "get-help Sync-RubrikTag -examples".
    For more information, type: "get-help Sync-RubrikTag -detailed".
    For technical information, type: "get-help Sync-RubrikTag -full".
    For online help, type: "get-help Sync-RubrikTag -online"



