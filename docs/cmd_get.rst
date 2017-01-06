Get Commands
=========================

This page contains details on **Get** commands.

Get-RubrikJob
-------------------------


NAME
    Get-RubrikJob
    
SYNOPSIS
    Connects to Rubrik and retrieves details on a back-end job
    
    
SYNTAX
    Get-RubrikJob [-id] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikJob cmdlet will accept a job ID value and return any information known about that specific 
    job
    

PARAMETERS
    -id <String>
        Rubrik job ID value
        
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
    
    PS C:\>Get-RubrikJob -ID 'MOUNT_SNAPSHOT_1234567890:::0'
    
    Will return details on the job ID MOUNT_SNAPSHOT_1234567890:::0
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikJob -examples".
    For more information, type: "get-help Get-RubrikJob -detailed".
    For technical information, type: "get-help Get-RubrikJob -full".
    For online help, type: "get-help Get-RubrikJob -online"

Get-RubrikMount
-------------------------

NAME
    Get-RubrikMount
    
SYNOPSIS
    Connects to Rubrik and retrieves details on mounts for a VM
    
    
SYNTAX
    Get-RubrikMount [[-VM] <String>] [[-MountID] <String>] [[-Server] <String>] [[-api] <String>] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikMount cmdlet will accept a VM name and return details on any mount operations that are 
    active within Rubrik
    

PARAMETERS
    -VM <String>
        Virtual Machine to inspect for mounts
        
    -MountID <String>
        The Rubrik ID value of the mount
        
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
    
    PS C:\>Get-RubrikMount
    
    Will return all Live Mounts known to Rubrik
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikMount -VM Server1
    
    Will return all Live Mounts found for Server1
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikMount -MountID 11111111-2222-3333-4444-555555555555
    
    Will return all Live Mounts found for the Rubrik ID 1234567890
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikMount -examples".
    For more information, type: "get-help Get-RubrikMount -detailed".
    For technical information, type: "get-help Get-RubrikMount -full".
    For online help, type: "get-help Get-RubrikMount -online"

Get-RubrikSLA
-------------------------

NAME
    Get-RubrikSLA
    
SYNOPSIS
    Connects to Rubrik and retrieves details on SLA Domain(s)
    
    
SYNTAX
    Get-RubrikSLA [[-SLA] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains. Information 
    on each
    domain will be reported to the console.
    

PARAMETERS
    -SLA <String>
        SLA Domain Name
        
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
    
    PS C:\>Get-RubrikSLA
    
    Will return all known SLA Domains
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikSLA -SLA 'Gold'
    
    Will return details on the SLA Domain named Gold
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikSLA -examples".
    For more information, type: "get-help Get-RubrikSLA -detailed".
    For technical information, type: "get-help Get-RubrikSLA -full".
    For online help, type: "get-help Get-RubrikSLA -online"

Get-RubrikSnapshot
-------------------------

NAME
    Get-RubrikSnapshot
    
SYNOPSIS
    Retrieves all of the snapshots (backups) for a given virtual machine
    
    
SYNTAX
    Get-RubrikSnapshot [-VM] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for a 
    protected virtual machine
    

PARAMETERS
    -VM <String>
        Name of the virtual machine
        
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
    
    PS C:\>Get-RubrikSnapshot -VM 'Server1'
    
    This will return an array of details for each snapshot (backup) for Server1
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikSnapshot -examples".
    For more information, type: "get-help Get-RubrikSnapshot -detailed".
    For technical information, type: "get-help Get-RubrikSnapshot -full".
    For online help, type: "get-help Get-RubrikSnapshot -online"

Get-RubrikVersion
-------------------------

NAME
    Get-RubrikVersion
    
SYNOPSIS
    Connects to Rubrik and retrieves the current version
    
    
SYNTAX
    Get-RubrikVersion [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system.
    

PARAMETERS
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
    
    PS C:\>Get-RubrikVersion
    
    This will return the running version on the Rubrik cluster
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikVersion -examples".
    For more information, type: "get-help Get-RubrikVersion -detailed".
    For technical information, type: "get-help Get-RubrikVersion -full".
    For online help, type: "get-help Get-RubrikVersion -online"

Get-RubrikVM
-------------------------

NAME
    Get-RubrikVM
    
SYNOPSIS
    Retrieves details on one or more virtual machines known to a Rubrik cluster
    
    
SYNTAX
    Get-RubrikVM [[-VM] <String>] [[-Filter] <String>] [[-SLA] <String>] [[-Server] <String>] [[-api] 
    <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of 
    virtual machines
    

PARAMETERS
    -VM <String>
        Name of the virtual machine
        If no value is specified, will retrieve information on all virtual machines
        
    -Filter <String>
        Filter results based on active, relic (removed), or all virtual machines
        
    -SLA <String>
        SLA Domain policy
        
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
    
    PS C:\>Get-RubrikVM -VM 'Server1'
    
    This will return the ID of the virtual machine named Server1
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikVM -examples".
    For more information, type: "get-help Get-RubrikVM -detailed".
    For technical information, type: "get-help Get-RubrikVM -full".
    For online help, type: "get-help Get-RubrikVM -online"



