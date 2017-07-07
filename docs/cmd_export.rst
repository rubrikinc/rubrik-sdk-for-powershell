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
    Export-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-TimestampMs <Int64>] [-FinishRecovery] [-TargetInstanceId <String>] [-TargetDatabaseName <String>] [-Server <String>] [-api <String>] [-TargetFilePaths 
    <PSObject[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Export-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-RecoveryDateTime <DateTime>] [-FinishRecovery] [-TargetInstanceId <String>] [-TargetDatabaseName <String>] [-Server <String>] [-api <String>] [-TargetFilePaths 
    <PSObject[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Export-RubrikDatabase command will request a database export from a Rubrik Cluster to a MSSQL instance
    

PARAMETERS
    -Id <String>
        Rubrik identifier of database to be exported
        
    -MaxDataStreams <Int32>
        Number of parallel streams to copy data
        
    -TimestampMs <Int64>
        Recovery Point desired in the form of Epoch with Milliseconds
        
    -RecoveryDateTime <DateTime>
        Recovery Point desired in the form of DateTime value
        
    -FinishRecovery [<SwitchParameter>]
        Take database out of recovery mode after export
        
    -TargetInstanceId <String>
        Rubrik identifier of MSSQL instance to export to
        
    -TargetDatabaseName <String>
        Name to give database upon export
        
    -Server <String>
        Rubrik server IP or FQDN
        
    -api <String>
        API version
        
    -TargetFilePaths <PSObject[]>
        Optional Export File Hash table Array
        
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
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Export-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -targetInstanceId $db2.instanceId -targetDatabaseName 'BAR_EXP' -targetFilePaths $targetfiles -maxDataStreams 1
    
    Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database. New file paths are 
    in the $targetfiles array:
    
    $targetfiles += @{logicalName='BAR_1';exportPath='E:\SQLFiles\Data\BAREXP\'}
     $targetfiles += @{logicalName='BAR_LOG';exportPath='E:\SQLFiles\Log\BAREXP\'}
    
    
    
    
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




