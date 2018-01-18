#requires -Version 3
function New-RubrikReport
{
  <#  
      .SYNOPSIS
      Create a new report by specifying one of the report templates

      .DESCRIPTION
      The New-RubrikReport cmdlet is used to create a new Envision report by specifying one of the canned report templates

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      New-RubrikReport -Name 'Report1' -ReportTemplate 'ProtectionTasksDetails'
      This will create a new report named "Report1" by using the "ProtectionTasksDetails" report template
  #>

  [CmdletBinding()]
  Param(
    # The name of the report
    [Parameter(Mandatory = $true)]
    [String]$Name,
    # The template this report is based on
    [Parameter(Mandatory = $true)]    
    [ValidateSet('ProtectionTasksDetails','ProtectionTasksSummary','SystemCapacity','SlaComplianceSummary')]
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