Export Commands
=========================

This page contains details on **Export** commands.

Export-RubrikDatabase
-------------------------


NAME
    Export-RubrikDatabase
    
SYNOPSIS
    Connects to Rubrik exports a database to a MSSQL instance
    
    
SYNTAX
    Export-RubrikDatabase [-id] <String> [[-maxDataStreams] <Int32>] [[-timestampMs] <Int64>] [-finishRecovery] [[-targetInstanceId] <String>] [[-targetDatabaseName] <String>] [[-Server] <String>] [[-api] <String>] [-WhatIf] 
    [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Export-RubrikDatabase command will request a database export from a Rubrik Cluster to a MSSQL instance
    

PARAMETERS
    -id <String>
        Rubrik identifier of database to be exported
        
    -maxDataStreams <Int32>
        Number of parallel streams to copy data
        
    -timestampMs <Int64>
        Recovery Point desired in the form of Epoch with Milliseconds
        
    -finishRecovery [<SwitchParameter>]
        Take database out of recovery mode after export
        
    -targetInstanceId <String>
        Rubrik identifier of MSSQL instance to export to
        
    -targetDatabaseName <String>
        Name to give database upon export
        
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
    
    PS C:\>Export-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -targetInstanceId MssqlInstance:::0085b247-e718-4177-869f-e3ae1f7bb503 -targetDatabaseName ReportServer -finishRecovery -maxDataStreams 4 
    -timestampMs 1492661627000
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-RubrikDatabase -examples".
    For more information, type: "get-help Export-RubrikDatabase -detailed".
    For technical information, type: "get-help Export-RubrikDatabase -full".
    For online help, type: "get-help Export-RubrikDatabase -online"


Export-RubrikReport
-------------------------

NAME
    Export-RubrikReport
    
SYNOPSIS
    Retrieves link to a CSV file for a Rubrik Envision report
    
    
SYNTAX
    Export-RubrikReport [-id] <String> [[-TimezoneOffset] <String>] [[-Server] <String>] [[-api] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    The Export-RubrikReport cmdlet is used to pull the link to a CSV file for a Rubrik Envision report
    

PARAMETERS
    -id <String>
        ID of the report.
        
    -TimezoneOffset <String>
        Timezone offset from UTC in minutes.
        
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
    
    PS C:\>Export-RubrikReport -id '11111111-2222-3333-4444-555555555555' -timezone_offset 120
    
    This will return the link to a CSV file for report id "11111111-2222-3333-4444-555555555555"
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-RubrikReport -Name 'Protection Tasks Details' | Export-RubrikReport
    
    This will return the link to a CSV file for report named "Protection Tasks Details"
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-RubrikReport -examples".
    For more information, type: "get-help Export-RubrikReport -detailed".
    For technical information, type: "get-help Export-RubrikReport -full".
    For online help, type: "get-help Export-RubrikReport -online"




