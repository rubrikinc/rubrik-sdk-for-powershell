#requires -Version 3
function Set-RubrikReport
{
  <#
      .SYNOPSIS
      Create a new report by specifying one of the report templates

      .DESCRIPTION
      The Set-RubrikReport cmdlet is used to create a new Envision report by specifying one of the canned report templates

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubrikreport

      .EXAMPLE
      Get-RubrikReport -Name 'Boring Report' | Set-RubrikReport -NewName 'Quokka Report'

      This will rename the report named 'Boring Report' to 'Quokka Report'
  #>

  [CmdletBinding()]
  Param(
    # The ID of the report.
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [String]$id,
    # The new name of the report
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [String]$Name,
    [alias('chart0')]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [PSCustomObject] $InputChart0,
    [alias('chart1')]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [PSCustomObject] $InputChart1,
    [alias('filters')]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [PSCustomObject] $InputFilters,
    [alias('table')]
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true )]
    [PSCustomObject] $InputTable,
    [string] $NewName,
    # The template this report is based on
    [Parameter(Mandatory = $true)]
    [ValidateSet('CapacityOverTime', 'ObjectProtectionSummary', 'ObjectTaskSummary', 'ObjectIndexingSummary', 'ProtectionTasksDetails', 'ProtectionTasksSummary', 'RecoveryTasksDetails', 'SlaComplianceSummary', 'SystemCapacity')]
    [String]$ReportTemplate,
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
    
    # Build body object
    $CurrentBody = [pscustomobject]@{
      name = $Name
      filters = $InputFilters
      chart0 = $InputChart0
      chart1 = $InputChart1
      table = $InputTable
    }
  }

  Process {

    switch ($true) {
      {$NewName} {$CurrentBody.Name = $NewName}
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = $CurrentBody | ConvertTo-Json -Depth 10
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function