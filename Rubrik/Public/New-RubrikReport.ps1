#Requires -Version 3
function New-RubrikReport
{
  <#  
      .SYNOPSIS
      Connects to Rubrik to retrieve either daily or weekly task results

      .DESCRIPTION
      The New-RubrikReport cmdlet is used to retrieve all of the tasks that have been run by a Rubrik cluster. Use either 'daily' or 'weekly' for ReportType to define the reporting scope.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikReport -ReportType daily -ToCSV
      This will gather all of the daily tasks from Rubrik and store them into a CSV file in the user's MyDocuments folder

      .EXAMPLE
      New-RubrikReport -ReportType weekly
      This will gather all of the daily tasks from Rubrik and display summary information on the console screen
  #>

  [CmdletBinding()]
  Param(
    # Report Type (daily or weekly)     
    [Parameter(Mandatory = $true,Position = 0)]
    [ValidateNotNullorEmpty()]
    [ValidateSet('daily', 'weekly')]
    [String]$ReportType,
    # Status Type
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [ValidateSet('Succeeded','Running','Failed','Canceled')]
    [String]$StatusType,
    # Export the results to a CSV file
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [Switch]$ToCSV,
    # Rubrik server IP or FQDN
    [Parameter(Position = 3)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 4)]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
        
    Write-Verbose -Message 'Gather API data'
    $resources = Get-RubrikAPIData -endpoint ('ReportBackupJobsDetailGet')
  
  }

  Process {
        
    Write-Verbose -Message 'Build the URI'
    $uri = 'https://'+$Server+$resources.$api.URI
    # Replace the placeholder of {id} with the actual VM ID
    $uri = $uri -replace '{id}', $ReportType.ToLower()
        
    Write-Verbose -Message 'Build the method'
    $method = $resources.$api.Method

    # v0 API Body is required since the call is a POST
    if ($api -eq 'v0') 
    {
      Write-Verbose -Message 'Build the body'
      $body = @{
        reportType = $ReportType.ToLower()
      }
    }
    # v1+ API Body is set to 'null' since the call is a GET
    # The Invoke-WebRequest cmdlet will just overlook the body
    else 
    {
      $body = $null
    }

    Write-Verbose -Message 'Submit the request'
    try
    {
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method -Body (ConvertTo-Json -InputObject $body)
      if ($r.StatusCode -ne $resources.$api.SuccessCode) 
      {
        Write-Warning -Message 'Did not receive successful status code from Rubrik'
        throw $_
      }

      Write-Verbose -Message 'Convert JSON content to PSObject (Max 64MB)'
      [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
      $resultraw = ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
            MaxJsonLength = 67108864
      }).DeserializeObject($r.Content))
    }
    catch
    {
      throw $_
    }
    
    # Strip out the overhead in the newer API builds
    if ($api -ne 'v0') 
    {
      $resultraw = $resultraw.data
    }

    Write-Verbose -Message 'Counting unique status values'
    [array]$StatusCount = $resultraw.status |
    Group-Object |
    Select-Object -Property Count, Name
    foreach ($_ in $StatusCount) 
    {
      Write-Verbose -Message "$($_.name): $($_.count)"
    }

    Write-Verbose -Message 'Determining if status filter is required'
    if ($StatusType) 
    {
      Write-Verbose -Message "Filtering based on $StatusType status"
      $result = $resultraw |
      Where-Object -FilterScript {
        $_.status -match $StatusType
      }
    }
    else 
    {
      Write-Verbose -Message 'No status filter found'
      $result = $resultraw
    }

    Write-Verbose -Message 'Validating that results were found'
    if (!$result) 
    {
      throw 'No results found'
    }

    if ($ToCSV)
    {
      Write-Verbose -Message 'Creating CSV'
      $CSVfilename = 'rubrik-tasks-export-'+(Get-Date).Ticks+'.csv'
      try 
      {
        foreach ($record in $result)
        {
          $record | Export-Csv -Append -Path "$Home\Documents\$CSVfilename" -NoTypeInformation -Force
        }
        Write-Verbose -Message "CSV export written to $Home\Documents\$CSVfilename" -Verbose
      }
      catch 
      {
        throw $_
      }
    }

    return $result

  } # End of process
} # End of function
