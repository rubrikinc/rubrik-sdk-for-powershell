Remove Commands
=========================

This page contains details on **Remove** commands.

Remove-RubrikMount
-------------------------


NAME
    Remove-RubrikMount
    
SYNOPSIS
    Connects to Rubrik and removes one or more live mounts
    
    
SYNTAX
    Remove-RubrikMount [-id] <String> [-Force] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts
    

PARAMETERS
    -id <String>
        The Rubrik ID value of the mount
        
    -Force [<SwitchParameter>]
        Force unmount to deal with situations where host has been moved.
        
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
    
    PS C:\>Remove-RubrikMount -id '11111111-2222-3333-4444-555555555555'
    
    This will remove mount id "11111111-2222-3333-4444-555555555555".
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikMount | Remove-RubrikMount
    
    This will remove all mounted virtual machines.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Remove-RubrikMount
    
    This will remove any mounts found using the virtual machine named "Server1" as a base reference.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikMount -examples".
    For more information, type: "get-help Remove-RubrikMount -detailed".
    For technical information, type: "get-help Remove-RubrikMount -full".
    For online help, type: "get-help Remove-RubrikMount -online"

Remove-RubrikSLA
-------------------------

NAME
    Remove-RubrikSLA
    
SYNOPSIS
    Connects to Rubrik and removes SLA Domains
    
    
SYNTAX
    Remove-RubrikSLA [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain.
    The SLA Domain must have zero protected objects (VMs, filesets, databases, etc.) in order to be successful.
    

PARAMETERS
    -id <String>
        SLA Domain id
        
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
    
    PS C:\>Get-RubrikSLA -SLA 'Gold' | Remove-RubrikSLA
    
    This will attempt to remove the Gold SLA Domain from Rubrik if there are no objects being protected by the policy
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikSLA -examples".
    For more information, type: "get-help Remove-RubrikSLA -detailed".
    For technical information, type: "get-help Remove-RubrikSLA -full".
    For online help, type: "get-help Remove-RubrikSLA -online"



