Protect Commands
=========================

This page contains details on **Protect** commands.

Protect-RubrikTag
-------------------------


NAME
    Protect-RubrikTag
    
SYNOPSIS
    Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value
    
    
SYNTAX
    Protect-RubrikTag [-Tag] <String> [-Category] <String> [[-SLA] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
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
        Rubrik SLA Domain
        
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
    Protect-RubrikVM [-VM] <String> [[-SLA] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikVM [-VM] <String> [[-DoNotProtect]] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Protect-RubrikVM [-VM] <String> [[-Inherit]] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster. The SLA Domain contains all policy-driven values 
    needed to protect workloads.
    

PARAMETERS
    -VM <String>
        Virtual machine name
        
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
    
    PS C:\>Protect-RubrikVM -VM 'Server1' -SLA 'Gold'
    
    This will assign the Gold SLA Domain to a VM named Server1
    
    
    
    
REMARKS
    To see the examples, type: "get-help Protect-RubrikVM -examples".
    For more information, type: "get-help Protect-RubrikVM -detailed".
    For technical information, type: "get-help Protect-RubrikVM -full".
    For online help, type: "get-help Protect-RubrikVM -online"



