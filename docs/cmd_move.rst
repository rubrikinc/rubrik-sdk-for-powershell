Move Commands
=========================

This page contains details on **Move** commands.

Move-RubrikMountVMDK
-------------------------


NAME
    Move-RubrikMountVMDK
    
SYNOPSIS
    Moves the VMDKs from a Live Mount to another VM
    
    
SYNTAX
    Move-RubrikMountVMDK [-SourceVM] <String> [-TargetVM] <String> [[-Date] <String>] [[-ExcludeDisk] <Array>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Move-RubrikMountVMDK [-Cleanup <String>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.
    

PARAMETERS
    -SourceVM <String>
        Source virtual machine to use as a Live Mount based on a previous backup
        
    -TargetVM <String>
        Target virtual machine to attach the Live Mount disk(s)
        
    -Date <String>
        Backup date to use for the Live Mount
        Will use the current date and time if no value is specified
        
    -ExcludeDisk <Array>
        An array of disks to exclude from presenting to the target virtual machine
        By default, all disks will be presented
        
    -Cleanup <String>
        The path to a cleanup file to remove the live mount and presented disks
        The cleanup file is created each time the command is run and stored in the $HOME path as a text file with a random number value
        The file contains the TargetVM name, MountID value, and a list of all presented disks
        
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
    
    PS C:\>Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM'
    
    This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
    The Live Mount's VMDKs would then be presented to the VM named "TargetVM"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -Date '01/30/2016 08:00'
    
    This will create a Live Mount using the January 30th 08:00AM snapshot of the VM named "SourceVM"
    The Live Mount's VMDKs would then be presented to the VM named "TargetVM"
    Note: The Date parameter will start at the time specified (in this case, 08:00am) and work backwards in time until it finds a snapshot.
    Precise timing is not required.
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -ExcludeDisk @(0,1)
    
    This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
    Disk 0 and 1 (the first and second disks) would be excluded from presentation to the VM named "TargetVM"
    Note: that for the "ExcludeDisk" array, the format is @(#,#,#,...) where each # represents a disk starting with 0.
    Example: To exclude the first and third disks, the value would be @(0,2).
    Example: To exclude just the first disk, use @(0).
    
    
    
    
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Move-RubrikMountVMDK -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'
    
    This will remove the disk(s) and live mount, effectively reversing the initial request
    This file is created each time the command is run and stored in the $HOME path as a text file
    The file contains the TargetVM name, MountID value, and a list of all presented disks
    
    
    
    
REMARKS
    To see the examples, type: "get-help Move-RubrikMountVMDK -examples".
    For more information, type: "get-help Move-RubrikMountVMDK -detailed".
    For technical information, type: "get-help Move-RubrikMountVMDK -full".
    For online help, type: "get-help Move-RubrikMountVMDK -online"




