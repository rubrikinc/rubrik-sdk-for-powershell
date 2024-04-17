function Get-RubrikRSCHyperVVM
{
  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the Hyper-V virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [String]$SLA,
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed Hyper-V VM object, the default behavior of the API is to only retrieve a subset of the full Hyper-V VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
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


  if ($id) {
    $query = New-RscQuery -GqlQuery hypervVirtualMachine
    $query.var.fid = $id
    $response = Invoke-RSC $query
  } else {
    $query = New-RSCQuery -GqlQuery hypervVirtualMachines
    
    Write-Verbose -Message "Filtering list by cluster"
    $filter = New-Object System.Collections.ArrayList

    $filter.Add(
      @{
        "field" = "CLUSTER_ID"
        "texts" = "$($global:rubrikConnection.clusterId)"
      }
    ) | Out-Null

    if ($SLA) {
        $sla_id = (Get-RubrikSLA -Name "$SLA").id
        if ($null -ne $sla_id){
          $SLAID = $sla_id
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
  
      if ($PSBoundParameters.containsKey("Relic")) {
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
  
      if ($SLAID) {
        $filter.Add(
          @{
            "field" = "EFFECTIVE_SLA"
            "texts" = "$SLAID"
          }
        ) | Out-null
      }

      Write-Verbose -Message "Adding filter to query"      
      $query.var.filter = $filter

      $response = (Invoke-Rsc $query).nodes



  }

  return $response



}