#Requires -Version 3
function Set-RubrikSLA
{
  <#  
      .SYNOPSIS
      Updates an existing Rubrik SLA Domain

      .DESCRIPTION
      The Set-RubrikSLA cmdlet will update an existing SLA Domain with specified parameters.

      .NOTES
      Written by Pierre-François Guglielmi for community usage
      Twitter: @pfguglielmi
      GitHub: pfguglielmi

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikSLA.html

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours
      while also keeping one backup per day for 30 days.

      .EXAMPLE
      Get-RubrikSLA -Name 'Silver (Managed by Polaris)' | Set-RubrikSLA -HourlyRetention 4 -HourlyFrequency 5 -Verbose
      Will get information of Silver SLA and only change the values specified in the Set-RubrikSLA function
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA id value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA Domain Name
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [Alias('SLA')]
    [String]$Name,
    # Hourly frequency to take backups
    [int]$HourlyFrequency,
    # Number of days or weeks to retain the hourly backups
    [int]$HourlyRetention,
    # Retention unit to apply to hourly snapshots
    [ValidateSet('Daily','Weekly')]
    [String]$HourlyRetentionUnit='Daily',
    # Daily frequency to take backups
    [int]$DailyFrequency,
    # Number of days or weeks to retain the daily backups
    [int]$DailyRetention,
    # Retention unit to apply to daily snapshots
    [ValidateSet('Daily','Weekly')]
    [String]$DailyRetentionUnit='Daily',
    # Weekly frequency to take backups
    [int]$WeeklyFrequency,
    # Number of weeks to retain the weekly backups
    [int]$WeeklyRetention,
    # Day of week for the weekly snapshots when $AdvancedConfig is set to $true. The default is Saturday
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [String]$DayOfWeek='Saturday',
    # Monthly frequency to take backups
    [int]$MonthlyFrequency,
    # Number of months, quarters or years to retain the monthly backups
    [int]$MonthlyRetention,
    # Day of month for the monthly snapshots when $AdvancedConfig is set to $true. The default is the last day of the month.
    [ValidateSet('FirstDay','Fifteenth','LastDay')]
    [String]$DayOfMonth='LastDay',
    # Retention unit to apply to monthly snapshots
    [ValidateSet('Monthly','Quarterly','Yearly')]
    [String]$MonthlyRetentionUnit='Monthly',
    # Quarterly frequency to take backups
    [int]$QuarterlyFrequency,
    # Number of quarters or years to retain the monthly backup
    [int]$QuarterlyRetention,
    # Day of quarter for the quarterly snapshots when $AdvancedConfig is set to $true. The default is the last day of the quarter.
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfQuarter='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is set to $true. The default is January.
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$FirstQuarterStartMonth='January',
    # Retention unit to apply to quarterly snapshots
    [ValidateSet('Quarterly','Yearly')]
    [String]$QuarterlyRetentionUnit='Quarterly',
    # Yearly frequency to take backups
    [int]$YearlyFrequency,
    # Number of years to retain the yearly backups
    [int]$YearlyRetention,
    # Day of year for the yearly snapshots when $AdvancedConfig is set to $true. The default is the last day of the year.
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfYear='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is set to $true. The default is January.
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$YearStartMonth='January',
    # Whether to turn advanced SLA configuration on or off. Only supported with CDM versions greater or equal to 5.0
    [switch]$AdvancedConfig,
    # Takes this object from Get-RubrikSLA
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [object[]] $Frequencies,
    # Takes this object from Get-RubrikSLA
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('advancedUiConfig')]
    [object[]] $AdvancedFreq,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message 'Build the body'
    $body = @{
      $resources.Body.name = $Name
      frequencies = @()
      showAdvancedUi = $AdvancedConfig.IsPresent
      advancedUiConfig = @()
    }
    
    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false

    if (($Frequencies) -and ($AdvancedConfig)) {
      $Frequencies[0].psobject.properties.name | ForEach-Object {
        if ($_ -eq 'Hourly') {
          if (($Frequencies.$_.frequency) -and (-not $HourlyFrequency)) {
            $HourlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $HourlyRetention)) {
            $HourlyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Daily') {
          if (($Frequencies.$_.frequency) -and (-not $DailyFrequency)) {
            $DailyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $DailyRetention)) {
            $DailyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Weekly') {
          if (($Frequencies.$_.frequency) -and (-not $WeeklyFrequency)) {
            $WeeklyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $WeeklyRetention)) {
            $WeeklyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfWeek) -and (-not $PSBoundParameters.ContainsKey('dayOfWeek'))) {
            $DayOfWeek = $Frequencies.$_.dayOfWeek
          }
        } elseif ($_ -eq 'Monthly') {
          if (($Frequencies.$_.frequency) -and (-not $MonthlyFrequency)) {
            $MonthlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $MonthlyRetention)) {
            $MonthlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfMonth) -and (-not $PSBoundParameters.ContainsKey('dayOfMonth'))) {
            $DayofMonth = $Frequencies.$_.dayOfMonth
          }
        } elseif ($_ -eq 'Quarterly') {
          if (($Frequencies.$_.frequency) -and (-not $QuarterlyFrequency)) {
            $QuarterlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $QuarterlyRetention)) {
            $QuarterlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.firstQuarterStartMonth) -and (-not $PSBoundParameters.ContainsKey('firstQuarterStartMonth'))) {
            $FirstQuarterStartMonth = $Frequencies.$_.firstQuarterStartMonth
          }
          if (($Frequencies.$_.dayOfQuarter) -and (-not $PSBoundParameters.ContainsKey('dayOfQuarter'))) {
            $DayOfQuarter = $Frequencies.$_.dayOfQuarter
          }
        } elseif ($_ -eq 'Yearly') {
          if (($Frequencies.$_.frequency) -and (-not $YearlyFrequency)) {
            $YearlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $YearlyRetention)) {
            $YearlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.yearStartMonth) -and (-not $PSBoundParameters.ContainsKey('yearStartMonth'))) {
            $YearStartMonth = $Frequencies.$_.yearStartMonth
          }
          if (($Frequencies.$_.dayOfYear) -and (-not $PSBoundParameters.ContainsKey('dayOfYear'))) {
            $DayOfYear = $Frequencies.$_.dayOfYear
          }
        }
      }
    } elseif (($Frequencies)) {
      $Frequencies[0].psobject.properties.name | ForEach-Object {
        if ($_ -eq 'Hourly') {
          if (($Frequencies.$_.frequency) -and (-not $HourlyFrequency)) {
            $HourlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $HourlyRetention)) {
            $HourlyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Daily') {
          if (($Frequencies.$_.frequency) -and (-not $DailyFrequency)) {
            $DailyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $DailyRetention)) {
            $DailyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Monthly') {
          if (($Frequencies.$_.frequency) -and (-not $MonthlyFrequency)) {
            $MonthlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $MonthlyRetention)) {
            $MonthlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfMonth) -and (-not $PSBoundParameters.ContainsKey('dayOfMonth'))) {
            $DayofMonth = $Frequencies.$_.dayOfMonth
          }
        } elseif ($_ -eq 'Yearly') {
          if (($Frequencies.$_.frequency) -and (-not $YearlyFrequency)) {
            $YearlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $YearlyRetention)) {
            $YearlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.yearStartMonth) -and (-not $PSBoundParameters.ContainsKey('yearStartMonth'))) {
            $YearStartMonth = $Frequencies.$_.yearStartMonth
          }
          if (($Frequencies.$_.dayOfYear) -and (-not $PSBoundParameters.ContainsKey('dayOfYear'))) {
            $DayOfYear = $Frequencies.$_.dayOfYear
          }
        }
      }
    }

    if ($AdvancedFreq) {
      $AdvancedFreq | ForEach-Object {
        if (($_.timeUnit -eq 'Hourly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('HourlyRetentionUnit'))) {
          $HourlyRetentionUnit = $_.retentionType

        } elseif (($_.timeUnit -eq 'Daily') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('DailyRetentionUnit'))) {
          $DailyRetentionUnit = $_.retentionType
        #} elseif (($_.timeUnit -eq 'Weekly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('WeeklyRetentionUnit'))) {
        #  $WeeklyRetentionUnit = $_.retentionType
        } elseif (($_.timeUnit -eq 'Monthly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('MonthlyRetentionUnit'))) {
          $MonthlyRetentionUnit = $_.retentionType
        } elseif (($_.timeUnit -eq 'Quarterly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('QuarterlyRetentionUnit'))) {
          $QuarterlyRetentionUnit = $_.retentionType
        }
        # elseif (($_.timeUnit -eq 'Yearly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('YearlyRetentionUnit'))) {
        #  $YearlyRetentionUnit = $_.retentionType
        #}
      }
    }
     
    if ($HourlyFrequency -and $HourlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
        $body.advancedUiConfig += @{timeUnit='Hourly';retentionType=$HourlyRetentionUnit}
      } elseif ($uri.contains('v2')) {
            $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
      } else {
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Hourly'
          $resources.Body.frequencies.frequency = $HourlyFrequency
          $resources.Body.frequencies.retention = $HourlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
        $body.advancedUiConfig += @{timeUnit='Daily';retentionType=$DailyRetentionUnit}
      } elseif ($uri.contains('v2')) {
            $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Daily'
          $resources.Body.frequencies.frequency = $DailyFrequency
          $resources.Body.frequencies.retention = $DailyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($WeeklyFrequency -and $WeeklyRetention) { 
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
        $body.advancedUiConfig += @{timeUnit='Weekly';retentionType='Weekly'}
      } elseif ($uri.contains('v2')) {
            $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention}}
      } else {
        Write-Warning -Message 'Weekly SLA configurations are not supported in this version of Rubrik CDM.'
        # $body.frequencies += @{
        #   $resources.Body.frequencies.timeUnit = 'Weekly'
        #   $resources.Body.frequencies.frequency = $WeeklyFrequency
        #   $resources.Body.frequencies.retention = $WeeklyRetention
        # }
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
        $body.advancedUiConfig += @{timeUnit='Monthly';retentionType=$MonthlyRetentionUnit}
      } elseif ($uri.contains('v2')) {
            $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Monthly'
          $resources.Body.frequencies.frequency = $MonthlyFrequency
          $resources.Body.frequencies.retention = $MonthlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }  

    if ($QuarterlyFrequency -and $QuarterlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
          $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
          $body.advancedUiConfig += @{timeUnit='Quarterly';retentionType=$QuarterlyRetentionUnit}
      } elseif ($uri.contains('v2')) {
            $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention}}
      } else { 
        Write-Warning -Message 'Quarterly SLA configurations are not supported in this version of Rubrik CDM.'
        # $body.frequencies += @{
        #   $resources.Body.frequencies.timeUnit = 'ly'
        #   $resources.Body.frequencies.frequency = $MonthlyFrequency
        #   $resources.Body.frequencies.retention = $MonthlyRetention
        # }
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig)) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
        $body.advancedUiConfig += @{timeUnit='Yearly';retentionType='Yearly'}
      } elseif ($uri.contains('v2')) {  
            $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
      } else {  
          $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Yearly'
          $resources.Body.frequencies.frequency = $YearlyFrequency
          $resources.Body.frequencies.retention = $YearlyRetention
        }
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }    
    
    $body = ConvertTo-Json $body -Depth 10
    Write-Verbose -Message "Header = $header"
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function