Remove Commands
=========================

This page contains details on **Remove** commands.

Remove-RubrikFileset
-------------------------


NAME
    Remove-RubrikFileset
    
SYNOPSIS
    Delete a fileset by specifying the fileset ID
    
    
SYNTAX
    Remove-RubrikFileset [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikFileset cmdlet is used to remove a fileset registered with the Rubrik cluster.
    

PARAMETERS
    -id <String>
        The Rubrik ID value of the fileset
        
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
    
    PS C:\>Get-RubrikFileset -Name 'C_Drive' | Remove-RubrikHost
    
    This will remove any fileset that matches the name "C_Drive"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Remove-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
    
    This will specifically remove the fileset id matching "Fileset:::111111-2222-3333-4444-555555555555"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikFileset -examples".
    For more information, type: "get-help Remove-RubrikFileset -detailed".
    For technical information, type: "get-help Remove-RubrikFileset -full".
    For online help, type: "get-help Remove-RubrikFileset -online"


Remove-RubrikHost
-------------------------

NAME
    Remove-RubrikHost
    
SYNOPSIS
    Delete host by specifying the host ID.
    
    
SYNTAX
    Remove-RubrikHost [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikHost cmdlet is used to remove a host registered with the Rubrik cluster.
    

PARAMETERS
    -id <String>
        The Rubrik ID value of the host
        
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
    
    PS C:\>Get-RubrikHost -Name 'Server1.example.com' | Remove-RubrikHost
    
    This will remove a host that matches the name "Server1.example.com"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Remove-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
    
    This will specifically remove the host id matching "Host:::111111-2222-3333-4444-555555555555"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikHost -examples".
    For more information, type: "get-help Remove-RubrikHost -detailed".
    For technical information, type: "get-help Remove-RubrikHost -full".
    For online help, type: "get-help Remove-RubrikHost -online"


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


Remove-RubrikReport
-------------------------

NAME
    Remove-RubrikReport
    
SYNOPSIS
    Removes one or more reports created in Rubrik Envision
    
    
SYNTAX
    Remove-RubrikReport [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikReport cmdlet is used to delete any number of Rubrik Envision reports
    

PARAMETERS
    -id <String>
        The Rubrik ID value of the report
        
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
    
    PS C:\>Get-RubrikReport | Remove-RubrikReport -Confirm:$true
    
    This will delete all reports and force confirmation for each delete operation
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikReport -Name 'SLA' -Type Custom | Remove-RubrikReport
    
    This will delete all custom reports that contain the string "SLA"
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikReport -id '11111111-2222-3333-4444-555555555555' | Remove-RubrikReport -Confirm:$false
    
    This will delete the report id "11111111-2222-3333-4444-555555555555" without confirmation
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikReport -examples".
    For more information, type: "get-help Remove-RubrikReport -detailed".
    For technical information, type: "get-help Remove-RubrikReport -full".
    For online help, type: "get-help Remove-RubrikReport -online"


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


Remove-RubrikUnmanagedObject
-------------------------

NAME
    Remove-RubrikUnmanagedObject
    
SYNOPSIS
    Removes one or more unmanaged objects known to a Rubrik cluster
    
    
SYNTAX
    Remove-RubrikUnmanagedObject [-id] <String> [-Type] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Remove-RubrikUnmanagedObject cmdlet is used to remove unmanaged objects that have been stored in the cluster
    In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)
    

PARAMETERS
    -id <String>
        The id of the unmanaged object.
        
    -Type <String>
        The type of the unmanaged object. This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.
        
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
    
    PS C:\>Get-RubrikUnmanagedObject | Remove-RubrikUnmanagedObject
    
    This will remove all unmanaged objects from the cluster
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikUnmanagedObject -Type 'WindowsFileset' | Remove-RubrikUnmanagedObject -Confirm:$false
    
    This will remove any unmanaged objects related to filesets applied to Windows Servers and supress confirmation for each activity
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1' | Remove-RubrikUnmanagedObject
    
    This will remove any unmanaged objects associated with any workload named "Server1" that is currently unprotected
    
    
    
    
REMARKS
    To see the examples, type: "get-help Remove-RubrikUnmanagedObject -examples".
    For more information, type: "get-help Remove-RubrikUnmanagedObject -detailed".
    For technical information, type: "get-help Remove-RubrikUnmanagedObject -full".
    For online help, type: "get-help Remove-RubrikUnmanagedObject -online"




