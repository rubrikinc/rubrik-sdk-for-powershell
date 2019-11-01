#Requires -Version 3
function Get-RubrikDatabaseRecoveryPoint {
    <#  
        .SYNOPSIS
        Retrieves a date time combination either from Rubrik API calls or with entered information that is formated for use by other Rubrik cmdlets

        .DESCRIPTION
        The Get-RubrikDatabaseRecoveryPoint cmdlet is used to pull date time combination from either Get-RubrikDatabase or Get-RubrikSnapshot based on a database ID.
        When we pull the value from those cmdlets, we will use that in Export-RubrikDatabase, New-RubrikDatabaseMount, Restore-RubrikDatabase. We will also pass in a time
        to get back a date time combination or an exact time. ALl results will be returned back in UTC so that the cmdlets can properly perform their functions. 

        .PARAMETER RubrikDatabaseID
        Provide an ID of a database that is returned back from Get-RubrikDatabase
        .PARAMETER Latest
        A time  to which the database should be restored to.
        latest:             This will tell Rubrik to export the database to the latest recovery point Rubrik knows about
                            This will include the last full and any logs to get to the latest recovery point
        .PARAMETER Latest
        A time  to which the database should be restored to.
        last full:          This will tell Rubrik to restore back to the last full backup it has
        
        .PARAMETER RestoreTime
        A time  to which the database should be restored to.
        Format:             (HH:MM:SS.mmm) at the point in time specified within the last 24 hours
        Format:             Any valid <value> that PS Get-Date supports in: "Get-Date -Date <Value>"
            Example: "2018-08-01T02:00:00.000Z" restores back to 2AM on August 1, 2018 UTC.

        .NOTES
        Written by Chris Lumnah for community usage
        Twitter: @lumnah
        GitHub: clumnah

        .LINK
        http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDatabaseRecoverypoint.html

        .EXAMPLE
        Get-RubrikDatabaseRecoveryPoint -id "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -Latest 
        This will return back a date time combination that prepresents the latest recovery point known to Rubrik about this database. This will include the last snapshot and any transaction log backup taken since that 
        last snapshot was taken. 

        .EXAMPLE
        Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -LastFull
        This will return back a date time combination that prepresents the recovery point known to Rubrik about this database based on the most recent snapshot taken.

        .EXAMPLE
        Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -RestoreTime 02:00:00
        This will return back a date time combination that represents todays date at 2am, but converted to UTC. The time entered into the RestoreTime field will be in local time. 

        .EXAMPLE
        Get-RubrikDatabaseRecoveryPoint -id  "MssqlDatabase:::10dd9979-fdcb-4dc2-b212-20efffd39102" -RestoreTime "2019-10-19 20:00:00"
        This will return back a date time combination that represents the local date time value entered into the RestoreTme field, converted to UTC. 
    #>
    param(
        # Rubrik's database id value
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] 
        [string]$id,
        [Parameter(ParameterSetName = 'Latest')]
        [switch]$Latest,
        [Parameter(ParameterSetName = 'LastFull')]
        [switch]$LastFull,
        [Parameter(ParameterSetName = 'RestoreTime')]
        [datetime]$RestoreTime
    )
    if ($PSBoundParameters.ContainsKey('Latest')) {
        $LatestRecoveryPoint = (Get-RubrikDatabase -id $id ).latestRecoveryPoint
        $RecoveryDateTime = $LatestRecoveryPoint
    }
    if ($PSBoundParameters.ContainsKey('LastFull')) {
        $RubrikSnapshot = Get-RubrikSnapshot -id $id  | Sort-Object date -Descending | Select-object -First 1
        $RecoveryDateTime = $RubrikSnapshot.date
    }
    if ($PSBoundParameters.ContainsKey('RestoreTime')) {
        $RawRestoreDate = (get-date -Date $RestoreTime)
        Write-Verbose ("RawRestoreDate is: $RawRestoreDate")
        $Now = (Get-Date).ToUniversalTime()
        if ($RawRestoreDate -ge $Now) { 
            $RecoveryDateTime = $RawRestoreDate.AddDays(-1)
            Write-Verbose ("RecoveryDateTime is: $RecoveryDateTime") 
        } 
        else { $RecoveryDateTime = $RawRestoreDate }
        $RecoveryDateTime = $RecoveryDateTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    }
    return $RecoveryDateTime
}
