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
    New-RubrikMount [-VM] <String> [[-MountName] <String>] [[-Date] <String>] [-HostID <String>] [-PowerOn] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
    

PARAMETERS
    -VM <String>
        Name of the virtual machine
        
    -MountName <String>
        An optional name for the Live Mount
        By default, will use the original VM name plus a date and instance number
        
    -Date <String>
        Date of the snapshot to use for the Live Mount
        Format should match MM/DD/YY HH:MM
        If no value is specified, will retrieve the last known shapshot
        
    -HostID <String>
        ID of the host for the Live Mount to use
        Defaults to the hostId where the running virtual machine lives
        
    -PowerOn [<SwitchParameter>]
        Select the power state of the Live Mount
        Defaults to $false (powered off)
        
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
    
    PS C:\>New-RubrikMount -VM 'Server1' -Date '05/04/2015 08:00'
    
    This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal to or older than 08:00 AM on May 4th, 2015
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikMount -VM 'Server1'
    
    This will create a new Live Mount for the virtual machine named Server1 based on the first snapshot that is equal to or older the current time (now)
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikMount -examples".
    For more information, type: "get-help New-RubrikMount -detailed".
    For technical information, type: "get-help New-RubrikMount -full".
    For online help, type: "get-help New-RubrikMount -online"

New-RubrikReport
-------------------------

NAME
    New-RubrikReport
    
SYNOPSIS
    Connects to Rubrik to retrieve either daily or weekly task results
    
    
SYNTAX
    New-RubrikReport [-ReportType] <String> [[-StatusType] <String>] [[-ToCSV]] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikReport cmdlet is used to retrieve all of the tasks that have been run by a Rubrik cluster. Use either 'daily' or 'weekly' for ReportType to define 
    the reporting scope.
    

PARAMETERS
    -ReportType <String>
        Report Type (daily or weekly)
        
    -StatusType <String>
        Status Type
        
    -ToCSV [<SwitchParameter>]
        Export the results to a CSV file
        
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
    
    PS C:\>New-RubrikReport -ReportType daily -ToCSV
    
    This will gather all of the daily tasks from Rubrik and store them into a CSV file in the user's MyDocuments folder
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikReport -ReportType weekly
    
    This will gather all of the daily tasks from Rubrik and display summary information on the console screen
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikReport -examples".
    For more information, type: "get-help New-RubrikReport -detailed".
    For technical information, type: "get-help New-RubrikReport -full".
    For online help, type: "get-help New-RubrikReport -online"

New-RubrikSLA
-------------------------

NAME
    New-RubrikSLA
    
SYNOPSIS
    Creates a new Rubrik SLA Domain
    
    
SYNTAX
    New-RubrikSLA [-SLA] <String> [-HourlyFrequency <Int32>] [-HourlyRetention <Int32>] [-DailyFrequency <Int32>] [-DailyRetention <Int32>] [-MonthlyFrequency 
    <Int32>] [-MonthlyRetention <Int32>] [-YearlyFrequency <Int32>] [-YearlyRetention <Int32>] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.
    

PARAMETERS
    -SLA <String>
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
    
    PS C:\>New-RubrikSLA -SLA Test1 -HourlyFrequency 4 -HourlyRetention 24
    
    This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-RubrikSLA -SLA Test1 -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
    
    This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours while also
    keeping one backup per day for 30 days.
    
    
    
    
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
    New-RubrikSnapshot [-VM] <String> [[-Server] <String>] [[-api] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific virtual machine. This will be taken by Rubrik and stored in the VM's chain of 
    snapshots.
    

PARAMETERS
    -VM <String>
        Virtual machine name
        
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
    
    PS C:\>New-RubrikSnapshot -VM 'Server1'
    
    This will trigger an on-demand backup for the virtual machine named Server1
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-RubrikSnapshot -examples".
    For more information, type: "get-help New-RubrikSnapshot -detailed".
    For technical information, type: "get-help New-RubrikSnapshot -full".
    For online help, type: "get-help New-RubrikSnapshot -online"



