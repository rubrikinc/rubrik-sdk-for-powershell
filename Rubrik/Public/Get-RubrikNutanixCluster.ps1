#Requires -Version 3
function Get-RubrikNutanixCluster
{
  <#
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Nutanix Clusters

      .DESCRIPTION
      The Get-RubrikNutanixCluster cmdlet will retrieve the all the Nutanix Cluster settings actively running on the system.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
     https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubriknutanixcluster

      .EXAMPLE
      Get-RubrikNutanixCluster
      This will return all the Nutanix Clusters and their associated settings currently known to the Rubrik cluster

      .EXAMPLE
      Get-RubrikNutanixCluster -GetConnectionStatus
      This will return all the Nutanix Clusters and their associated settings, including their connection status which are currently known to the Rubrik cluster

      .EXAMPLE
      Get-RubrikNutanixCluster -PrimaryClusterId "local" -Name "ProductionCluster"
      This will return all the Nutanix Clusters named ProductionCluster currently associated with the cluster in which the API is authenticated to

      .EXAMPLE
      Get-RubrikNutanixCluster -Hostname "nutanix.domain.local"
      This will return all the Nutanix Clusters with a hostname of "nutanix.domain.local" currently known to the Rubrik cluster

    #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Nutanix Cluster Id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # Nutanix Cluster Name
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # Nutanix Cluster hostname
    [ValidateNotNullOrEmpty()]
    [String]$Hostname,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [ValidateNotNullOrEmpty()]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Should the connection status be retrieved. Retrieving the connection status could adversly affect performance
    [Alias('should_get_status')]
    [Switch]$GetConnectionStatus,
    # DetailedObject will retrieved the detailed Nutanix clusterobject, the default behavior of the API is to only retrieve a subset of the full Nutanix Cluster object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
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
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # If the Get-RubrikNutanixCluster function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResults -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result
  } # End of process
} # End of function