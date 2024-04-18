function Get-RubrikRSCVolumeGroup {
    [CmdletBinding()]
  Param(
    # Name of the volume group
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('VolumeGroup')]
    [String]$name,
    # Filter results by hostname
    [String]$hostname,
    # Filter results to include only relic (removed) volume groups
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the volume group
    [String]$SLA,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Volume group id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed VolumeGroup object, the default behavior of the API is to only retrieve a subset of the full VolumeGroup object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

    $query = New-RscQuery -GqlQuery physicalHosts
    $query.Var.hostRoot = "WINDOWS_HOST_ROOT"
    $query.Var.sortBy = "NAME"
    $query.Var.sortOrder = "ASC"
    $query.Var
    $filter = New-Object System.Collections.ArrayList


    #TODO -=MWP=- figure out how to get volume group info into query
    $filter.Add(
      @{
        "field" = "CLUSTER_ID"
        "texts" = "$($global:rubrikConnection.clusterId)"
      }
    ) | Out-Null
    $filter.Add(
        @{
          "field" = "IS_REPLICATED"
          "texts" = "$false"
        }
      ) | Out-Null
    if ($PSBoundParameters.containsKey("Relic"))  {
        if ($Relic -eq $true) {
            $filter.Add(
                @{
                  "field" = "IS_RELIC"
                  "texts" = "True"
                }
              ) | out-null
        } elseif ($Relic -eq $false) {
            $filter.Add(
                @{
                  "field" = "IS_RELIC"
                  "texts" = "False"
                }
              ) | out-null
        }
    }

    if ($Name) {
        $filter.Add(
            @{
              "field" = "NAME_EXACT_MATCH"
              "texts" = "$Name"
            }
          ) | Out-Null
      }
    Write-Verbose -Message "Adding filter to query"      
    $query.var.filter = $filter
    
    $response = (Invoke-Rsc $query).nodes
    return $response

}