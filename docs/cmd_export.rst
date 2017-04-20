Export Commands
=========================

This page contains details on **Export** commands.

Export-RubrikDatabase
-------------------------


NAME
    Export-RubrikDatabase
    
SYNOPSIS
    Connects to Rubrik exports a database to an SQL instance
    
    
SYNTAX
    Export-RubrikDatabase [-id] <String> [[-maxDataStreams] <Int32>] [[-timestampMs] <Int64>] [-finishRecovery] [[-targetInstanceId] <String>] [[-targetDatabaseName] <String>] [[-Server] <String>] [[-api] 
    <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Export-RubrikDatabase command will accept the following baseline vari
    in order to request a database export to an SQL instance:
    
    id (string) - Rubrik identifier of database to be exported
       (MssqlDatabase:::30290af0-9522-44ef-98ab-b2e2bfb59ccb)
    targetInstanceId (string)- Rubrik identifier of MSSQL instance to export to
    targetDatabaseName (string) - Name to give database upon export
    finishRecovery (switch) - Keep database in recovery mode after export
    maxDataStreams (int) - Number of parallel streams to copy data
    timestampMs (int) - Recovery Point desired in the form of Epoch
                        with Milliseconds
    

PARAMETERS
    -id <String>
        Rubrik identifier of database to be exported
        
    -maxDataStreams <Int32>
        Number of parallel streams to copy data
        
    -timestampMs <Int64>
        Recovery Point desired in the form of Epoch with Milliseconds
        
    -finishRecovery [<SwitchParameter>]
        Keep database in recovery mode after export
        
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
    
    PS C:\>Set-RubrikBlackout -Set [true/false]
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help Export-RubrikDatabase -examples".
    For more information, type: "get-help Export-RubrikDatabase -detailed".
    For technical information, type: "get-help Export-RubrikDatabase -full".
    For online help, type: "get-help Export-RubrikDatabase -online"



