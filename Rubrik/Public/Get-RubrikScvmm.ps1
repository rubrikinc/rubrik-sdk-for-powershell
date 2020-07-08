#Requires -Version 3
function Get-RubrikScvmm
{
  <#
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Rubrik SCVMM server settings

      .DESCRIPTION
      The Get-RubrikScvmm cmdlet will retrieve SCVMM servers and settings currently configured on the cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
     https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikscvmm

      .EXAMPLE
      Get-RubrikScvmm
      This will return all of the SCVMM servers and associated settings on the currently connected Rubrik cluster

      .EXAMPLE
      Get-RubrikScvmm -Name 'scvmm.domain.local'
      This will return the SCVMM server settings for the SCVMM server named 'scvmm.domain.local'

      .EXAMPLE
      Get-RubrikScvmm -PrimaryClusterId '1111-2222-3333'
      This will return the SCVMM server settings any server directly attached to the cluster with an id of '1111-2222-3333'

      .EXAMPLE
      Get-RubrikScvmm -Id '1111-2222-3333'
      This will return the SCVMM server settings with an id of '1111-2222-3333'

      .EXAMPLE
      Get-RubrikScvmm -SLA 'Gold'
      This will return the SCVMM server settings any server assigned to the Gold SLA Domain on the cluster
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # SCVMM Server ID
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # SCVMM Server Name
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='Query',
        Position = 0)]
    [String]$Name,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [ValidateNotNullOrEmpty()]
    [Parameter(ParameterSetName='Query')]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # DetailedObject will retrieved the detailed SCVMM object, the default behavior of the API is to only retrieve a subset of the full SCVMM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [Alias('sla_assignment')]
    [String]$SLAAssignment,
    # SLA Domain policy assigned to the SCVMM Server
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
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

    #region One-off
    if ($SLAID.Length -eq 0 -and $SLA.Length -gt 0) {
        $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -PrimaryClusterID $PrimaryClusterID
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # if detailed object is passed, loop through to get more information

    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id')) -and ($result.total -ne 0) -and ($null -ne $result))  {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResult -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result


  } # End of process
} # End of function