New Commands
=========================

This page contains details on **New** commands.

New-RubrikMount
-------------------------


NAME
    New-RubrikMount
    
SYNOPSIS
    Create a new Live Mount from a protected VM
    
    
SYNTAX
    New-RubrikMount [-id] <String> [[-HostID] <String>] [[-MountName] <String>] [[-DatastoreName] <String>] [-DisableNetwork] [-RemoveNetworkDevices] [-PowerState] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
    

PARAMETERS
    -id <String>
        Rubrik id of the snapshot
        
    -HostID <String>
        ID of host for the mount to use
        
    -MountName <String>
        Name of the mounted VM
        
    -DatastoreName <String>
        Name of the data store to use/create on the host
        
    -DisableNetwork [<SwitchParameter>]
        Whether the network should be disabled on mount.This should be set true to avoid ip conflict in case of static IPs.
        
    -RemoveNetworkDevices [<SwitchParameter>]
        Whether the network devices should be removed on mount.
        
    -PowerState [<SwitchParameter>]
        Whether the VM should be powered on after mount.
        
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
    
    PS C:\>New-RubrikMount -id '11111111-2222-3333-4444-555555555555'
    
    This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555"
    The original virtual machine's name will be used along with a date and index number suffix
    The virtual machine will be powered on upon completion of the mount operation
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikMount -id '11111111-2222-3333-4444-555555555555' -MountName 'Mount1' -PowerState:$false
    
    This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555" and name the mounted virtual machine "Mount1"
    The virtual machine will NOT be powered on upon completion of the mount operation
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/01/2017 01:00' | New-RubrikMount -MountName 'Mount1' -DisableNetwork
    
    This will create a new mount based on the closet snapshot found on March 1st, 2017 @ 01:00 AM and name the mounted virtual machine "Mount1"
    The virtual machine will be powered on upon completion of the mount operation
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikMount -examples".
    For more information, type: "get-help New-RubrikMount -detailed".
    For technical information, type: "get-help New-RubrikMount -full".
    For online help, type: "get-help New-RubrikMount -online"

New-RubrikSLA
-------------------------

NAME
    New-RubrikSLA
    
SYNOPSIS
    Creates a new Rubrik SLA Domain
    
    
SYNTAX
    New-RubrikSLA [-Name] <String> [[-HourlyFrequency] <Int32>] [[-HourlyRetention] <Int32>] [[-DailyFrequency] <Int32>] [[-DailyRetention] <Int32>] [[-MonthlyFrequency] <Int32>] [[-MonthlyRetention] <Int32>] [[-YearlyFrequency] <Int32>] 
    [[-YearlyRetention] <Int32>] [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.
    

PARAMETERS
    -Name <String>
        SLA Domain Name
        
    -HourlyFrequency <Int32>
        Hourly frequency to take backups
        
    -HourlyRetention <Int32>
        Number of hours to retain the hourly backups
        
    -DailyFrequency <Int32>
        Daily frequency to take backups
        
    -DailyRetention <Int32>
        Number of days to retain the daily backups
        
    -MonthlyFrequency <Int32>
        Monthly frequency to take backups
        
    -MonthlyRetention <Int32>
        Number of months to retain the monthly backups
        
    -YearlyFrequency <Int32>
        Yearly frequency to take backups
        
    -YearlyRetention <Int32>
        Number of years to retain the yearly backups
        
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
    
    PS C:\>New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24
    
    This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
    
    This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours
    while also keeping one backup per day for 30 days.
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikSLA -examples".
    For more information, type: "get-help New-RubrikSLA -detailed".
    For technical information, type: "get-help New-RubrikSLA -full".
    For online help, type: "get-help New-RubrikSLA -online"

New-RubrikSnapshot
-------------------------

NAME
    New-RubrikSnapshot
    
SYNOPSIS
    Takes a Rubrik snapshot of a virtual machine
    
    
SYNTAX
    New-RubrikSnapshot [-id] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be taken by Rubrik and stored in the VM's chain of snapshots.
    

PARAMETERS
    -id <String>
        Virtual machine id
        
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
    
    PS C:\>Get-RubrikVM 'Server1' | New-RubrikSnapshot
    
    This will trigger an on-demand backup for the virtual machine named "Server1"
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikSnapshot -examples".
    For more information, type: "get-help New-RubrikSnapshot -detailed".
    For technical information, type: "get-help New-RubrikSnapshot -full".
    For online help, type: "get-help New-RubrikSnapshot -online"



