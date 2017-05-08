Protect Commands
=========================

This page contains details on **Protect** commands.

Protect-RubrikDatabase
-------------------------


NAME
    Protect-RubrikDatabase
    
SYNOPSIS
    Connects to Rubrik and assigns an SLA to a database
    
    
SYNTAX
    Protect-RubrikDatabase -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikDatabase -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikDatabase -id <String> [-Inherit] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Protect-RubrikDatabase cmdlet will update a database's SLA Domain assignment within the Rubrik cluster.
    The SLA Domain contains all policy-driven values needed to protect workloads.
    Note that this function requires the Database ID value, not the name of the database, since database names are not unique across hosts.
    It is suggested that you first use Get-RubrikDatabase to narrow down the one or more database / instance / hosts to protect, and then pipe the results to Protect-RubrikDatabase.
    You will be asked to confirm each database you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
    

PARAMETERS
    -id <String>
        Database ID
        
    -SLA <String>
        The SLA Domain in Rubrik
        
    -DoNotProtect [<SwitchParameter>]
        Removes the SLA Domain assignment
        
    -Inherit [<SwitchParameter>]
        Inherits the SLA Domain assignment from a parent object
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikDatabase "DB1" | Protect-RubrikDatabase -SLA 'Gold'
    
    This will assign the Gold SLA Domain to any database named "DB1"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikDatabase "DB1" -Instance "MSSQLSERVER" | Protect-RubrikDatabase -SLA 'Gold' -Confirm:$False
    
    This will assign the Gold SLA Domain to any database named "DB1" residing on an instance named "MSSQLSERVER" without asking for confirmation
    
    
    
    
REMARKS
    To see the examples, type: "get-help Protect-RubrikDatabase -examples".
    For more information, type: "get-help Protect-RubrikDatabase -detailed".
    For technical information, type: "get-help Protect-RubrikDatabase -full".
    For online help, type: "get-help Protect-RubrikDatabase -online"


Protect-RubrikFileset
-------------------------

NAME
    Protect-RubrikFileset
    
SYNOPSIS
    Connects to Rubrik and assigns an SLA to a fileset
    
    
SYNTAX
    Protect-RubrikFileset -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikFileset -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Protect-RubrikFileset cmdlet will update a fileset's SLA Domain assignment within the Rubrik cluster.
    The SLA Domain contains all policy-driven values needed to protect data.
    Note that this function requires the fileset ID value, not the name of the fileset, since fileset names are not unique across clusters.
    It is suggested that you first use Get-RubrikFileset to narrow down the one or more filesets to protect, and then pipe the results to Protect-RubrikFileset.
    You will be asked to confirm each fileset you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
    

PARAMETERS
    -id <String>
        Fileset ID
        
    -SLA <String>
        The SLA Domain in Rubrik
        
    -DoNotProtect [<SwitchParameter>]
        Removes the SLA Domain assignment
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikFileset 'C_Drive' | Protect-RubrikFileset -SLA 'Gold'
    
    This will assign the Gold SLA Domain to any fileset named "C_Drive"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -Confirm:$False
    
    This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" without asking for confirmation
    
    
    
    
REMARKS
    To see the examples, type: "get-help Protect-RubrikFileset -examples".
    For more information, type: "get-help Protect-RubrikFileset -detailed".
    For technical information, type: "get-help Protect-RubrikFileset -full".
    For online help, type: "get-help Protect-RubrikFileset -online"


Protect-RubrikTag
-------------------------

NAME
    Protect-RubrikTag
    
SYNOPSIS
    Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value
    
    
SYNTAX
    Protect-RubrikTag -Tag <String> -Category <String> [-SLA <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikTag -Tag <String> -Category <String> [-DoNotProtect] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikTag -Tag <String> -Category <String> [-Inherit] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
    The SLA Domain contains all policy-driven values needed to protect workloads.
    Make sure you have PowerCLI installed and connect to the required vCenter Server.
    

PARAMETERS
    -Tag <String>
        vSphere Tag
        
    -Category <String>
        vSphere Tag Category
        
    -SLA <String>
        The SLA Domain in Rubrik
        
    -DoNotProtect [<SwitchParameter>]
        Removes the SLA Domain assignment
        
    -Inherit [<SwitchParameter>]
        Inherits the SLA Domain assignment from a parent object
        
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
    
    PS C:\>Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik'
    
    This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium'
    
    This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -DoNotProtect
    
    This will remove protection from any VM tagged with Gold in the Rubrik category
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -Inherit
    
    This will flag any VM tagged with Gold in the Rubrik category to inherit the SLA Domain of its parent object
    
    
    
    
REMARKS
    To see the examples, type: "get-help Protect-RubrikTag -examples".
    For more information, type: "get-help Protect-RubrikTag -detailed".
    For technical information, type: "get-help Protect-RubrikTag -full".
    For online help, type: "get-help Protect-RubrikTag -online"


Protect-RubrikVM
-------------------------

NAME
    Protect-RubrikVM
    
SYNOPSIS
    Connects to Rubrik and assigns an SLA to a virtual machine
    
    
SYNTAX
    Protect-RubrikVM -id <String> [-SLA <String>] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikVM -id <String> [-DoNotProtect] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikVM -id <String> [-Inherit] [-SLAID <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
    The SLA Domain contains all policy-driven values needed to protect workloads.
    Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
    It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
    You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
    

PARAMETERS
    -id <String>
        Virtual machine ID
        
    -SLA <String>
        The SLA Domain in Rubrik
        
    -DoNotProtect [<SwitchParameter>]
        Removes the SLA Domain assignment
        
    -Inherit [<SwitchParameter>]
        Inherits the SLA Domain assignment from a parent object
        
    -SLAID <String>
        SLA id value
        
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
    
    PS C:\>Get-RubrikVM "VM1" | Protect-RubrikVM -SLA 'Gold'
    
    This will assign the Gold SLA Domain to any virtual machine named "VM1"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikVM "VM1" -SLA Silver | Protect-RubrikVM -SLA 'Gold' -Confirm:$False
    
    This will assign the Gold SLA Domain to any virtual machine named "VM1" that is currently assigned to the Silver SLA Domain
    without asking for confirmation
    
    
    
    
REMARKS
    To see the examples, type: "get-help Protect-RubrikVM -examples".
    For more information, type: "get-help Protect-RubrikVM -detailed".
    For technical information, type: "get-help Protect-RubrikVM -full".
    For online help, type: "get-help Protect-RubrikVM -online"




