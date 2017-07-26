Restore Commands
=========================

This page contains details on **Restore** commands.

Restore-RubrikDatabase
-------------------------


NAME
    Restore-RubrikDatabase
    
SYNOPSIS
    Connects to Rubrik and restores a MSSQL database
    
    
SYNTAX
    Restore-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-TimestampMs <Int64>] [-FinishRecovery] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    Restore-RubrikDatabase -Id <String> [-MaxDataStreams <Int32>] [-RecoveryDateTime <DateTime>] [-FinishRecovery] [-Server <String>] [-api <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    The Restore-RubrikDatabase command will request a database restore from a Rubrik Cluster to a MSSQL instance. This
    is an inplace restore, meaning it will overwrite the existing asset.
    

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
        If FinishRecover is true, fully recover the database
        
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
    
    PS C:\>Restore-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -targetInstanceId MssqlInstance:::0085b247-e718-4177-869f-e3ae1f7bb503 -FinishRecovery -maxDataStreams 4 -timestampMs 1492661627000
    
    Restore database to declared epoch ms timestamp.
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Restore-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -maxDataStreams 1 -FinishRecovery
    
    Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database.
    
    
    
    
REMARKS
    To see the examples, type: "get-help Restore-RubrikDatabase -examples".
    For more information, type: "get-help Restore-RubrikDatabase -detailed".
    For technical information, type: "get-help Restore-RubrikDatabase -full".
    For online help, type: "get-help Restore-RubrikDatabase -online"




