Set Commands
=========================

This page contains details on **Set** commands.

Set-RubrikVM
-------------------------


NAME
    Set-RubrikVM
    
SYNOPSIS
    Applies settings on one or more virtual machines known to a Rubrik cluster
    
    
SYNTAX
    Set-RubrikVM [-VM] <String> [[-SnapConsistency] <String>] [[-MaxNestedSnapshots] <Int32>] [[-PauseBackups] <String>] [-Server <String>] [-api <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Set-RubrikVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines
    

PARAMETERS
    -VM <String>
        Virtual machine name
        
    -SnapConsistency <String>
        Backup consistency type
        Choices are AUTO or CRASH_CONSISTENT
        
    -MaxNestedSnapshots <Int32>
        The number of existing virtual machine snapshots allowed by Rubrik
        If this value is exceeded, backups will be prevented due to seeing too many existing snapshots
        Keeping snapshots open on a virtual machine can adversely affect performance and increase consolidation times
        Choices range from 0 - 4 snapshots
        
    -PauseBackups <String>
        Set to $true to enable backups for a particular virtual machine
        Set to $false to disable backups for a particular virtual machine
        
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
    
    PS C:\>Set-RubrikVM -VM 'Server1' -SnapConsistency AUTO
    
    This will configure the backup consistency type for Server1 to Automatic (try for application consistency and fail to crash consistency).
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>(Get-RubrikVM -VM * -SLA 'Example').name | Set-RubrikVM -SnapConsistency AUTO
    
    This will gather the name of all VMs belonging to the SLA Domain named Example and configure the backup consistency type to be crash consistent.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Set-RubrikVM -examples".
    For more information, type: "get-help Set-RubrikVM -detailed".
    For technical information, type: "get-help Set-RubrikVM -full".
    For online help, type: "get-help Set-RubrikVM -online"



