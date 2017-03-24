#Requires -Version 3
function New-RubrikSLA
{
  <#  
      .SYNOPSIS
      Creates a new Rubrik SLA Domain

      .DESCRIPTION
      The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikSLA -SLA Test1 -HourlyFrequency 4 -HourlyRetention 24
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.

      .EXAMPLE
      New-RubrikSLA -SLA Test1 -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours while also
      keeping one backup per day for 30 days.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain Name
    [Parameter(Mandatory = $true,Position = 0)]
    [Alias('Name')]
    [ValidateNotNullorEmpty()]
    [String]$SLA,
    # Hourly frequency to take backups
    [int]$HourlyFrequency,
    # Number of hours to retain the hourly backups
    [int]$HourlyRetention,
    # Daily frequency to take backups
    [int]$DailyFrequency,
    # Number of days to retain the daily backups
    [int]$DailyRetention,
    # Monthly frequency to take backups
    [int]$MonthlyFrequency,
    # Number of months to retain the monthly backups
    [int]$MonthlyRetention,
    # Yearly frequency to take backups
    [int]$YearlyFrequency,
    # Number of years to retain the yearly backups
    [int]$YearlyRetention,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('SLADomainPost')
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI

    Write-Verbose -Message 'Build the body'
    $body = @{
      $resources.$api.Params.name = $SLA
      frequencies = @()
    }
    
    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false
      
    if ($HourlyFrequency -and $HourlyRetention)
    { 
      $body.frequencies += @{
        $resources.$api.Params.frequencies.timeUnit = 'Hourly'
        $resources.$api.Params.frequencies.frequency = $HourlyFrequency
        $resources.$api.Params.frequencies.retention = $HourlyRetention
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention)
    { 
      $body.frequencies += @{
        $resources.$api.Params.frequencies.timeUnit = 'Daily'
        $resources.$api.Params.frequencies.frequency = $DailyFrequency
        $resources.$api.Params.frequencies.retention = $DailyRetention
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention)
    { 
      $body.frequencies += @{
        $resources.$api.Params.frequencies.timeUnit = 'Monthly'
        $resources.$api.Params.frequencies.frequency = $MonthlyFrequency
        $resources.$api.Params.frequencies.retention = $MonthlyRetention
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention)
    { 
      $body.frequencies += @{
        $resources.$api.Params.frequencies.timeUnit = 'Yearly'
        $resources.$api.Params.frequencies.frequency = $YearlyFrequency
        $resources.$api.Params.frequencies.retention = $YearlyRetention
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }

    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    Write-Verbose -Message 'Submit the request'
    try
    {
      if ($PSCmdlet.ShouldProcess($SLA,'creating SLA Domain'))
      {
        $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
        if ($r.StatusCode -ne $resources.$api.SuccessCode) 
        {
          Write-Warning -Message 'Did not receive successful status code from Rubrik'
          throw $_
        }
        $response = ConvertFrom-Json -InputObject $r.Content
        return $response.statuses
      }
    }
    catch
    {
      throw $_
    }


  } # End of process
} # End of function