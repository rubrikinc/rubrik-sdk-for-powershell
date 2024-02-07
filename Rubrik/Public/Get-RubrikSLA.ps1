#Requires -Version 3
function Get-RubrikSLA
{
<#
  .SYNOPSIS
  Connects to Rubrik and retrieves details on SLA Domain(s)

  .DESCRIPTION
  The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
  Information on each domain will be reported to the console.

  .NOTES
  Written by Chris Wahl for community usage
  Twitter: @ChrisWahl
  GitHub: chriswahl

  .LINK
  https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriksla

  .EXAMPLE
  Get-RubrikSLA

  Will return all known SLA Domains

  .EXAMPLE
  Get-RubrikSLA -Name 'Gold'

  Will return details on the SLA Domain named Gold

  .EXAMPLE
  Get-RubrikSLA -Name 'Gold' -DetailedObject
  
  Will return information the SLA Domain named Gold, including full details on this SLA
#>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the SLA Domain
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('SLA')]
    [String]$Name,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # SLA Domain id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # DetailedObject will retrieved the detailed SLA object, the default behavior of the API is to only retrieve a subset of the full SLA object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    # If connected to RSC, redirect to new GQL cmdlet
    if ($global:rubrikConnection.RSCInstance) {
      Write-Verbose -Message "Cluster connected to RSC instance, redirecting to Get-RubrikRSCSla"
      $response = Get-RubrikRSCSla @PSBoundParameters
      return $response
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = $result | Select-Object -Property *,@{N="FrequencySummary";E={Get-RubrikSLAFrequencySummary -SLADomain $_}}

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        if ($result) {
          Get-RubrikSLA -id $result[$i].id
        }
      }
    } else {
      $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
      return $result
    }
  } # End of process
} # End of function