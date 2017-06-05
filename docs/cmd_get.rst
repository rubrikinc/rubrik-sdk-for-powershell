Get Commands
=========================

This page contains details on **Get** commands.

Get-RubrikDatabase
-------------------------


NAME
    Get-RubrikDatabase
    
SYNOPSIS
    Retrieves details on one or more databases known to a Rubrik cluster
    
    
SYNTAX
    Get-RubrikDatabase [[-Name] <String>] [-Relic] [[-SLA] <String>] [[-Instance] <String>] [[-Hostname] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-SLAID] <String>] [[-Server] <String>] [[-api] <String>] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikDatabase cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of databases.
    To narrow down the results, use the host and instance parameters to limit your search to a smaller group of objects.
    Alternatively, supply the Rubrik database ID to return only one specific database.
    

PARAMETERS
    -Name <String>
        Name of the database
        
    -Relic [<SwitchParameter>]
        Filter results to include only relic (removed) databases
        
    -SLA <String>
        SLA Domain policy assigned to the database
        
    -Instance <String>
        Name of the database instance
        
    -Hostname <String>
        Name of the database host
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        Rubrik's database id value
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikDatabase -Name 'DB1' -SLA Gold
    
    This will return details on all databases named DB1 protected by the Gold SLA Domain on any known host or instance.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikDatabase -Name 'DB1' -Host 'Host1' -Instance 'MSSQLSERVER'
    
    This will return details on a database named "DB1" living on an instance named "MSSQLSERVER" on the host named "Host1".
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikDatabase -Relic
    
    This will return all removed databases that were formerly protected by Rubrik.
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-RubrikDatabase -id 'MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    
    This will return details on a single database matching the Rubrik ID of "MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    Note that the database ID is globally unique and is often handy to know if tracking a specific database for longer workflows,
    whereas some values are not unique (such as nearly all hosts having one or more databases named "model") and more difficult to track by name.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikDatabase -examples".
    For more information, type: "get-help Get-RubrikDatabase -detailed".
    For technical information, type: "get-help Get-RubrikDatabase -full".
    For online help, type: "get-help Get-RubrikDatabase -online"


Get-RubrikFileset
-------------------------

NAME
    Get-RubrikFileset
    
SYNOPSIS
    Retrieves details on one or more filesets known to a Rubrik cluster
    
    
SYNTAX
    Get-RubrikFileset [[-Name] <String>] [-Relic] [[-SLA] <String>] [[-HostName] <String>] [[-TemplateID] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-SLAID] <String>] [[-Server] <String>] [[-api] <String>] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikFileset cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of filesets
    A number of parameters exist to help narrow down the specific fileset desired
    Note that a fileset name is not required; you can use params (such as HostName and SLA) to do lookup matching filesets
    

PARAMETERS
    -Name <String>
        Name of the fileset
        
    -Relic [<SwitchParameter>]
        Filter results to include only relic (removed) filesets
        
    -SLA <String>
        SLA Domain policy assigned to the database
        
    -HostName <String>
        Name of the host using a fileset
        
    -TemplateID <String>
        Filter the summary information based on the ID of a fileset template.
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        Rubrik's fileset id
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikFileset -Name 'C_Drive'
    
    This will return details on the fileset named "C_Drive" assigned to any hosts
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
    
    This will return details on the fileset named "C_Drive" assigned to only the "Server1" host
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikFileset -Name 'C_Drive' -SLA Gold
    
    This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
    
    This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"
    
    
    
    
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>Get-RubrikFileset -Relic
    
    This will return all removed filesets that were formerly protected by Rubrik.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikFileset -examples".
    For more information, type: "get-help Get-RubrikFileset -detailed".
    For technical information, type: "get-help Get-RubrikFileset -full".
    For online help, type: "get-help Get-RubrikFileset -online"


Get-RubrikFilesetTemplate
-------------------------

NAME
    Get-RubrikFilesetTemplate
    
SYNOPSIS
    Retrieves details on one or more fileset templates known to a Rubrik cluster
    
    
SYNTAX
    Get-RubrikFilesetTemplate [[-Name] <String>] [[-OperatingSystemType] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikFilesetTemplate cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of fileset templates
    

PARAMETERS
    -Name <String>
        Retrieve fileset templates with a name matching the provided name. The search is performed as a case-insensitive infix search.
        
    -OperatingSystemType <String>
        Filter the summary information based on the operating system type of the fileset. Accepted values: 'Windows', 'Linux'
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        The ID of the fileset template
        
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
    
    PS C:\>Get-RubrikFilesetTemplate -Name 'Template1'
    
    This will return details on all fileset templates named "Template1"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikFilesetTemplate -OperatingSystemType 'Linux'
    
    This will return details on all fileset templates that can be used against a Linux operating system type
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikFilesetTemplate -id '11111111-2222-3333-4444-555555555555'
    
    This will return details on the fileset template matching id "11111111-2222-3333-4444-555555555555"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikFilesetTemplate -examples".
    For more information, type: "get-help Get-RubrikFilesetTemplate -detailed".
    For technical information, type: "get-help Get-RubrikFilesetTemplate -full".
    For online help, type: "get-help Get-RubrikFilesetTemplate -online"


Get-RubrikHost
-------------------------

NAME
    Get-RubrikHost
    
SYNOPSIS
    Retrieve summary information for all hosts that are registered with a Rubrik cluster.
    
    
SYNTAX
    Get-RubrikHost [[-Name] <String>] [[-Type] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikHost cmdlet is used to retrive information on one or more hosts that are being protected with the Rubrik Backup Service or directly as with the case of NAS shares.
    

PARAMETERS
    -Name <String>
        Retrieve hosts with a host name matching the provided name. The search type is infix
        
    -Type <String>
        Filter the summary information based on the operating system type. Accepted values are 'Windows', 'Linux', 'ANY', 'NONE'. Use NONE to only return information for hosts templates that do not have operating system type 
        set. Use ANY to only return information for hosts that have operating system type set.
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        ID of the registered host
        
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
    
    PS C:\>Get-RubrikHost
    
    This will return all known hosts
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikHost -Hostname 'Server1'
    
    This will return details on any hostname matching "Server1"
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikHost -Type 'Windows' -PrimaryClusterID 'local'
    
    This will return details on all Windows hosts that are being protected by the local Rubrik cluster
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
    
    This will return details specifically for the host id matching "Host:::111111-2222-3333-4444-555555555555"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikHost -examples".
    For more information, type: "get-help Get-RubrikHost -detailed".
    For technical information, type: "get-help Get-RubrikHost -full".
    For online help, type: "get-help Get-RubrikHost -online"


Get-RubrikMount
-------------------------

NAME
    Get-RubrikMount
    
SYNOPSIS
    Connects to Rubrik and retrieves details on mounts for a VM
    
    
SYNTAX
    Get-RubrikMount [[-id] <String>] [[-VMID] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
    Due to the nature of names not being unique
    Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
    It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikMount.
    

PARAMETERS
    -id <String>
        Rubrik's id of the mount
        
    -VMID <String>
        Filters live mounts by VM ID
        
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
    
    This will return details on all mounted virtual machines.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikMount -id '11111111-2222-3333-4444-555555555555'
    
    This will return details on mount id "11111111-2222-3333-4444-555555555555".
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id
    
    This will return details for any mounts found using the id value from a virtual machine named "Server1" as a base reference.
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-RubrikMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
    
    This will return details for any mounts found using the virtual machine id of 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' as a base reference.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikMount -examples".
    For more information, type: "get-help Get-RubrikMount -detailed".
    For technical information, type: "get-help Get-RubrikMount -full".
    For online help, type: "get-help Get-RubrikMount -online"


Get-RubrikReport
-------------------------

NAME
    Get-RubrikReport
    
SYNOPSIS
    Retrieves details on one or more reports created in Rubrik Envision
    
    
SYNTAX
    Get-RubrikReport [[-Name] <String>] [[-Type] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikReport cmdlet is used to pull information on any number of Rubrik Envision reports
    

PARAMETERS
    -Name <String>
        Filter the returned reports based off their name.
        
    -Type <String>
        Filter the returned reports based off the reports type. Options are Canned and Custom.
        
    -id <String>
        The ID of the report.
        
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
    
    PS C:\>Get-RubrikReport
    
    This will return details on all reports
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikReport -Name 'SLA' -Type Custom
    
    This will return details on all custom reports that contain the string "SLA"
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikReport -id '11111111-2222-3333-4444-555555555555'
    
    This will return details on the report id "11111111-2222-3333-4444-555555555555"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikReport -examples".
    For more information, type: "get-help Get-RubrikReport -detailed".
    For technical information, type: "get-help Get-RubrikReport -full".
    For online help, type: "get-help Get-RubrikReport -online"


Get-RubrikRequest
-------------------------

NAME
    Get-RubrikRequest
    
SYNOPSIS
    Connects to Rubrik and retrieves details on an async request
    
    
SYNTAX
    Get-RubrikRequest [-id] <String> [-Type] <String> [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
    This is helpful for tracking the state (success, failure, running, etc.) of a request.
    

PARAMETERS
    -id <String>
        ID of an asynchronous request
        
    -Type <String>
        The type of request
        
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
    
    PS C:\>Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
    
    Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikRequest -examples".
    For more information, type: "get-help Get-RubrikRequest -detailed".
    For technical information, type: "get-help Get-RubrikRequest -full".
    For online help, type: "get-help Get-RubrikRequest -online"


Get-RubrikSLA
-------------------------

NAME
    Get-RubrikSLA
    
SYNOPSIS
    Connects to Rubrik and retrieves details on SLA Domain(s)
    
    
SYNTAX
    Get-RubrikSLA [[-Name] <String>] [[-PrimaryClusterID] <String>] [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
    Information on each domain will be reported to the console.
    

PARAMETERS
    -Name <String>
        Name of the SLA Domain
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        SLA Domain id
        
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
    
    PS C:\>Get-RubrikSLA -Name 'Gold'
    
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
    Retrieves all of the snapshots (backups) for any given object
    
    
SYNTAX
    Get-RubrikSnapshot [-id] <String> [[-CloudState] <Int32>] [-OnDemandSnapshot] [[-Date] <DateTime>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for any protected object
    The correct API call will be made based on the object id submitted
    Multiple objects can be piped into this function so long as they contain the id required for lookup
    

PARAMETERS
    -id <String>
        Rubrik id of the protected object
        
    -CloudState <Int32>
        Filter results based on where in the cloud the snapshot lives
        
    -OnDemandSnapshot [<SwitchParameter>]
        Filter results to show only snapshots that were created on demand
        
    -Date <DateTime>
        Date of the snapshot
        
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
    
    PS C:\>Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
    
    This will return all snapshot (backup) data for the virtual machine id of "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017'
    
    This will return the closest matching snapshot to March 21st, 2017 for any virtual machine named "Server1"
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikDatabase 'DB1' | Get-RubrikSnapshot -OnDemandSnapshot
    
    This will return the details on any on-demand (user initiated) snapshot to for any database named "DB1"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikSnapshot -examples".
    For more information, type: "get-help Get-RubrikSnapshot -detailed".
    For technical information, type: "get-help Get-RubrikSnapshot -full".
    For online help, type: "get-help Get-RubrikSnapshot -online"


Get-RubrikUnmanagedObject
-------------------------

NAME
    Get-RubrikUnmanagedObject
    
SYNOPSIS
    Retrieves details on one or more unmanaged objects known to a Rubrik cluster
    
    
SYNTAX
    Get-RubrikUnmanagedObject [[-Name] <String>] [[-Status] <String>] [[-Type] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikUnmanagedObject cmdlet is used to pull details on any unmanaged objects that has been stored in the cluster
    In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)
    

PARAMETERS
    -Name <String>
        Search object by object name.
        
    -Status <String>
        Filter by the type of the object. If not specified, will return all objects. Valid attributes are Protected, Relic and Unprotected
        
    -Type <String>
        The type of the unmanaged object. This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.
        
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
    
    PS C:\>Get-RubrikUnmanagedObject -Type 'WindowsFileset'
    
    This will return details on any filesets applied to Windows Servers that have unmanaged snapshots associated
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1'
    
    This will return details on any objects named "Server1" that are currently unprotected and have unmanaged snapshots associated
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikUnmanagedObject -examples".
    For more information, type: "get-help Get-RubrikUnmanagedObject -detailed".
    For technical information, type: "get-help Get-RubrikUnmanagedObject -full".
    For online help, type: "get-help Get-RubrikUnmanagedObject -online"


Get-RubrikVersion
-------------------------

NAME
    Get-RubrikVersion
    
SYNOPSIS
    Connects to Rubrik and retrieves the current version
    
    
SYNTAX
    Get-RubrikVersion [[-id] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system.
    

PARAMETERS
    -id <String>
        ID of the Rubrik cluster or me for self
        
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
    Get-RubrikVM [[-Name] <String>] [-Relic] [-SLA <String>] [-SLAAssignment <String>] [-PrimaryClusterID <String>] [-id <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of virtual machines
    

PARAMETERS
    -Name <String>
        Name of the virtual machine
        
    -Relic [<SwitchParameter>]
        Filter results to include only relic (removed) virtual machines
        
    -SLA <String>
        SLA Domain policy assigned to the virtual machine
        
    -SLAAssignment <String>
        Filter by SLA Domain assignment type
        
    -PrimaryClusterID <String>
        Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
        
    -id <String>
        Virtual machine id
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikVM -Name 'Server1'
    
    This will return details on all virtual machines named "Server1".
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikVM -Name 'Server1' -SLA Gold
    
    This will return details on all virtual machines named "Server1" that are protected by the Gold SLA Domain.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikVM -Relic
    
    This will return all removed virtual machines that were formerly protected by Rubrik.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Get-RubrikVM -examples".
    For more information, type: "get-help Get-RubrikVM -detailed".
    For technical information, type: "get-help Get-RubrikVM -full".
    For online help, type: "get-help Get-RubrikVM -online"




