#Requires -Version 3
function Get-RubrikSnapshotByDate()
{
    Param (
      [String]$Date
    )

    try 
    {
        Write-Verbose -Message 'Query Rubrik for the protected VM snapshot list'
        $snapshots = Get-RubrikSnapshot -VM $VM

        Write-Verbose -Message 'Comparing backup dates to user date'
        $Date = ConvertFromLocalDate -Date $Date
        
        Write-Verbose -Message 'Finding snapshots that match the date value'
        
        foreach ($_ in $snapshots)
        {
            if (([datetime]$_.date) -le ($Date) -eq $true)
            {
                $vmsnapid = $_.id
                Write-Verbose -Message "Found matching snapshot with ID $vmsnapid"
                break
            }
        }

        return $vmsnapid
    }
    catch 
    {
        throw $_
    }
}