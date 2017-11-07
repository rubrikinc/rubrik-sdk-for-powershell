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
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 24 -DailyFrequency 1 -DailyRetention 30
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 24 hours
      while also keeping one backup per day for 30 days.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain Name
    [Parameter(Mandatory = $true)]
    [Alias('SLA')]
    [String]$Name,
    # Hourly frequency to take backups
    [int]$HourlyFrequency,
    # Number of hours to retain the hourly backups
    [int]$HourlyRetention,
    # Daily frequency to take backups
    [int]$DailyFrequency,
    # Number of days to retain the daily backups
    [int]$DailyRetention,
    # Weekly frequency to take backups
    [int]$WeeklyFrequency,
    # Number of weeks to retain the weekly backups
    [int]$WeeklyRetention,
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

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = (Get-RubrikAPIData -endpoint $function).$api
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
    }
    
    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false
      
    if ($HourlyFrequency -and $HourlyRetention)
    { 
      $body.frequencies += @{
        $resources.Body.frequencies.timeUnit = 'Hourly'
        $resources.Body.frequencies.frequency = $HourlyFrequency
        $resources.Body.frequencies.retention = $HourlyRetention
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention)
    { 
      $body.frequencies += @{
        $resources.Body.frequencies.timeUnit = 'Daily'
        $resources.Body.frequencies.frequency = $DailyFrequency
        $resources.Body.frequencies.retention = $DailyRetention
      }
      [bool]$ParamValidation = $true
    }    

    if ($WeeklyFrequency -and $WeeklyRetention)
    { 
      Write-Warning -Message 'Weekly SLA configurations are not yet supported in the Rubrik web UI.'
      $body.frequencies += @{
        $resources.Body.frequencies.timeUnit = 'Weekly'
        $resources.Body.frequencies.frequency = $WeeklyFrequency
        $resources.Body.frequencies.retention = $WeeklyRetention
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention)
    { 
      $body.frequencies += @{
        $resources.Body.frequencies.timeUnit = 'Monthly'
        $resources.Body.frequencies.frequency = $MonthlyFrequency
        $resources.Body.frequencies.retention = $MonthlyRetention
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention)
    { 
      $body.frequencies += @{
        $resources.Body.frequencies.timeUnit = 'Yearly'
        $resources.Body.frequencies.frequency = $YearlyFrequency
        $resources.Body.frequencies.retention = $YearlyRetention
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }    
    
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function