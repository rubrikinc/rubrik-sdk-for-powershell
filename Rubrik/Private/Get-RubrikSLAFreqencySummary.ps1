function Get-RubrikSLAFrequencySummary{
    <#
        .SYNOPSIS
        Retrieves a human readable version of the SLA Frequency

        .DESCRIPTION
        Within Rubrik, SLA frequencies are very customizable. This function parses all of the advanced config to return
        a human readable summary of the frequencies configured.

        .NOTES
        Written by Mike Preston for community usage
        Twitter: @mwpreston
        GitHub: mwpreston

        .LINK
        https://github.com/rubrikinc/PowerShell-Module

        .EXAMPLE
        Get-RubrikSLAFrequencySummary -SLADomain (Get-RubrikSLA -Name "Gold")

    #>
      [CmdletBinding()]
      param(
          [psobject]$SLADomain
      )

    Write-Verbose -Message "Getting SLA Domain frequency summary"
    if ($null -ne $SLADomain.advancedUiConfig -and '' -ne $SLADomain.advancedUiConfig ) {
        $SLAFrequency = @()
        Write-Verbose -Message "Advanced config found, using this"
        if ($null -ne $SLADomain.frequencies.hourly.retention) {
            $HourlyRetentionType = ($SLADomain.advancedUiConfig | where {$_.timeUnit -eq 'Hourly'}).retentionType
            switch ($HourlyRetentionType) {
                "Weekly" { $HourlyRetention = "$($SLADomain.frequencies.hourly.retention) Week(s)" }
                "Daily" { $HourlyRetention = "$($SLADomain.frequencies.hourly.retention) Day(s)" }
            }

            $hourly = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.hourly.frequency) hour(s)"
                'Retain backups for' = $HourlyRetention
            }
            $SLAFrequency += [pscustomobject]$hourly
        }
        if ($null -ne $SLADomain.frequencies.daily.retention) {
            $DailyRetentionType = ($SLADomain.advancedUiConfig | where {$_.timeUnit -eq 'Daily'}).retentionType
            switch ($DailyRetentionType) {
                "Weekly" { $DailyRetention = "$($SLADomain.frequencies.daily.retention) Week(s)" }
                "Daily" { $DailyRetention = "$($SLADomain.frequencies.daily.retention) Day(s)" }
            }
            $daily = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.daily.frequency) day(s)"
                'Retain backups for' = $DailyRetention
            }
            $SLAFrequency += [pscustomobject]$daily
        }
        if ($null -ne $SLADomain.frequencies.weekly.retention) {
            #Weekly Retention is always weeks
            $WeeklyRetention = "$($SLADomain.frequencies.weekly.retention) Week(s)"
            $weekly = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.weekly.frequency) Week(s) on $($SLADomain.frequencies.weekly.dayOfWeek)"
                'Retain backups for' = $WeeklyRetention
            }
            $SLAFrequency += [pscustomobject]$weekly
        }
        if ($null -ne $SLADomain.frequencies.monthly.retention) {
            $MonthlyBackupTime = $SLADomain.frequencies.monthly.dayofMonth
            switch ($MonthlyBackupTime) {
                "LastDay" { $MonthStart = "the last day of the month."}
                "Fifteenth" { $MonthStart = "the 15th day of the month."}
                "FirstDay"  { $MonthStart = "the first day of the month."}
            }
            $MonthlyRetentionType = ($SLADomain.advancedUiConfig | where {$_.timeUnit -eq 'Monthly'}).retentionType
            switch ($MonthlyRetentionType) {
                "Monthly" { $MonthlyRetention = "$($SLADomain.frequencies.monthly.retention) Month(s)" }
                "Quarterly" { $MonthlyRetention = "$($SLADomain.frequencies.monthly.retention) Quarter(s)" }
                "Yearly" { $MonthlyRetention = "$($SLADomain.frequencies.monthly.retention) Year(s)" }
            }
            $monthly = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.monthly.frequency) Month(s) on $MonthStart"
                'Retain backups for' = $MonthlyRetention
            }
            $SLAFrequency += [pscustomobject]$monthly
        }
        if ($null -ne $SLADomain.frequencies.quarterly.retention) {
            $QuarterlyBackupTime = $SLADomain.frequencies.quarterly.dayofQuarter
            switch ($QuarterlyBackupTime) {
                "LastDay" { $QuarterStart = "the last day of the quarter"}
                "FirstDay"  { $QuarterStart = "the first day of the quarter"}
            }
            $QuarterMonthStart = $SLADomain.frequencies.quarterly.firstQuarterStartMonth

            $QuarterRetentionType = ($SLADomain.advancedUiConfig | where {$_.timeUnit -eq 'Quarterly'}).retentionType
            switch ($QuarterRetentionType) {
                "Quarterly" { $QuarterRetention = "$($SLADomain.frequencies.quarterly.retention) Quarter(s)" }
                "Yearly" { $QuarterRetention = "$($SLADomain.frequencies.quarterly.retention) Year(s)" }
            }
            $quarterly = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.quarterly.frequency) Quarter(s) on $QuarterStart beggining in $QuarterMonthStart"
                'Retain backups for' = $QuarterRetention
            }
            $SLAFrequency += [pscustomobject]$quarterly
        }
        if ($null -ne $SLADomain.frequencies.yearly.retention) {
            $YearlyBackupTime = $SLADomain.frequencies.yearly.dayOfYear
            switch ($YearlyBackupTime) {
                "LastDay" { $YearStart = "the last day of the year"}
                "FirstDay"  { $YearStart = "the first day of the year"}
            }
            $YearMonthStart = $SLADomain.frequencies.yearly.yearStartMonth

            #Yearly time unit is always years
            $YearlyRetention = "$($SLADomain.frequencies.yearly.retention) Year(s)"
            $yearly = [ordered]@{
                'Take backups every' = "$($SLADomain.frequencies.yearly.frequency) Year(s) on $YearStart beggining in $YearMonthStart"
                'Retain backups for' = $YearlyRetention
            }
            $SLAFrequency += [pscustomobject]$yearly
        }
    }
    else {
        Write-Verbose -Message "No advanced config found"
        $SLAFrequency = @()

        if ($null -ne $SLADomain.frequencies.hourly.retention) {
            if ($SLADomain.frequencies.hourly.retention -gt 23) {
                $HourlyRetention = "$($SLADomain.frequencies.hourly.retention/24) Day(s)"
            }
            else {$HourlyRetention = "$($SLADomain.frequencies.hourly.retention) Hour(s)" }
            $hourly = @{
                'Take backups every' = "$($SLADomain.frequencies.hourly.frequency) Hour(s)"
                'Retain backups for' = $HourlyRetention
            }
            $SLAFrequency += [pscustomobject]$hourly
        }
        if ($null -ne $SLADomain.frequencies.daily.retention) {
            $daily = @{
                'Take backups every' = "$($SLADomain.frequencies.daily.frequency) Day(s)"
                'Retain backups for' = "$($SLADomain.frequencies.daily.retention)  Day(s)"
            }
            $SLAFrequency += [pscustomobject]$daily
        }
        if ($null -ne $SLADomain.frequencies.monthly.retention) {
            $monthly = @{
                'Take backups every' = "$($SLADomain.frequencies.monthly.frequency) Month(s)"
                'Retain backups for' = "$($SLADomain.frequencies.monthly.retention)  Month(s)"
            }
            $SLAFrequency += [pscustomobject]$monthly
        }
        if ($null -ne $SLADomain.frequencies.yearly.retention) {
            $yearly = @{
                'Take backups every' = "$($SLADomain.frequencies.yearly.frequency) Year(s)"
                'Retain backups for' = "$($SLADomain.frequencies.yearly.retention)  Year(s)"
            }
            $SLAFrequency += [pscustomobject]$yearly
        }
    }
    Write-Verbose -Message "[Rubrik] [$($brik)] [SLA Domains] Output SLA Domain Frequency Settings"
    return $SLAFrequency
  }