Sync Commands
=========================

This page contains details on **Sync** commands.

Sync-RubrikAnnotation
-------------------------


NAME
    Sync-RubrikAnnotation
    
SYNOPSIS
    Applies Rubrik SLA Domain information to VM Annotations using the Custom Attributes feature in vCenter
    
    
SYNTAX
    Sync-RubrikAnnotation [[-SLA] <String>] [[-SLAAnnotationName] <String>] [[-BackupAnnotationName] <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Sync-RubrikAnnotation cmdlet will comb through all VMs currently being protected by Rubrik.
    It will then create Custom Attribute buckets for SLA Domain Name(s) and Snapshot counts and assign details for each VM found in vCenter using Annotations.
    The attribute names can be specified using this function's parameters or left as the defaults. See the examples for more information.
    Keep in mind that this only displays in the VMware vSphere Thick (C#) client, which is deprecated moving forward.
    

PARAMETERS
    -SLA <String>
        Optional filter for a single SLA Domain Name
        By default, all SLA Domain Names will be collected when this parameter is not used
        
    -SLAAnnotationName <String>
        Attribute name in vCenter for the Rubrik SLA Domain Name
        By default, will use "Rubrik_SLA"
        
    -BackupAnnotationName <String>
        Attribute name in vCenter for quantity of snapshots
        By default, will use "Rubrik_Backups"
        
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
    
    PS C:\>Sync-RubrikAnnotation
    
    This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
    using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Sync-RubrikAnnotation -SLA Silver
    
    This will find all VMs being protected with a Rubrik SLA Domain Name of "Silver" and update their SLA and snapshot count annotations
    using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Sync-RubrikAnnotation -SLAAnnotationName 'Backup-Policy' -BackupAnnotationName 'Backup-Snapshots'
    
    This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
    using the custom values of "Backup-Policy" and "Backup-Snapshots" respectively.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Sync-RubrikAnnotation -examples".
    For more information, type: "get-help Sync-RubrikAnnotation -detailed".
    For technical information, type: "get-help Sync-RubrikAnnotation -full".
    For online help, type: "get-help Sync-RubrikAnnotation -online"

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



