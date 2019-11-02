#requires -Version 3
function Get-RubrikReportData
{
  <#  
      .SYNOPSIS
      Retrieve table data for a specific Envision report

      .DESCRIPTION
      The Get-RubrikReportData cmdlet is used to pull table data from a specific Envision report

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikReportData

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData
      This will return table data from the "SLA Compliance Summary" report

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance'
      This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance"

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance' -Limit 10
      This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance", only returns the first 10 results.
  #>

  [CmdletBinding()]
  Param(
    # The ID of the report
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
    # Search table data by object name
    [Alias('search_value')]
    [String]$Name,
    # Filter table data on task type
    [Alias('task_type')]
    [String]$TaskType,
    # Filter table data on task status
    [Alias('task_status')]
    [String]$TaskStatus,
    # Filter table data on object type
    [Alias('object_type')]
    [String]$ObjectType,
    # Filter table data on compliance status
    [Alias('compliance_status')]
    [ValidateSet('InCompliance','NonCompliance')]
    [String]$ComplianceStatus,  
    #limit the number of rows returned, defaults to maximum pageSize of 9999
    [int]$limit,
    #cursor start (if necessary)
    [string]$cursor,
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
  
    # Set limit to default of 9999 if not set, both limit and psboundparameters are set, this is because New-BodyString builds the query using both variables
    if ($null -eq $PSBoundParameters.limit) {
      $PSBoundParameters.Add('limit',9999) | Out-Null
      $limit = 9999
    }
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
