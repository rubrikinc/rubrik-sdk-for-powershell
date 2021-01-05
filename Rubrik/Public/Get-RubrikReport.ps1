#requires -Version 3
function Get-RubrikReport
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more reports created in Rubrik Envision

      .DESCRIPTION
      The Get-RubrikReport cmdlet is used to pull information on any number of Rubrik Envision reports

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikreport

      .EXAMPLE
      Get-RubrikReport

      This will return details on all reports

      .EXAMPLE
      Get-RubrikReport -DetailedObject

      This will return full details on all reports

      .EXAMPLE
      Get-RubrikReport -Name 'SLA' -Type Custom

      This will return details on all custom reports that contain the string "SLA"

      .EXAMPLE
      Get-RubrikReport -id '11111111-2222-3333-4444-555555555555'

      This will return details on the report id "11111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikReport -Name 'Protection Tasks Details' | Get-RubrikReportData
      
      Using the pipeline in combination with Get-RubrikReportData additional information and report data are retrieved

      .EXAMPLE
      Get-RubrikReport -Name 'Protection Tasks Details' | Get-RubrikReportData | Select-Object -ExpandProperty DatagridObject

      Using the pipeline in combination with Get-RubrikReportData additional information and report data are retrieved. Using Select-Object to dig into the individual Protection Tasks
  #>

  [CmdletBinding()]
  Param(
    # Filter the returned reports based off their name.
    [Alias('search_text')]
    [String]$Name,
    # Filter the returned reports based off the reports type. Options are Canned and Custom.
    [ValidateSet('Canned', 'Custom')]
    [Alias('report_type')]
    [String]$Type,
    # The ID of the report.
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
    # DetailedObject will retrieved the detailed Rubrik Report object, the default behavior of the API is to only retrieve a subset of the full Rubrik Report object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
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
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        if ($result) {
          Get-RubrikReport -id $result[$i].id
        }
      }
    } else {
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function