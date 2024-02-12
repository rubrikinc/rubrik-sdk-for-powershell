function Get-RubrikRSCSLA {
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

    if ($PSBoundParameters['Name']) {
      $filter = @{
          "field" = "NAME"
          "text" = "$($Name)"
      }
      $query = New-RSCQuery -GqlQuery slaDomains
      $query.var.filter = $filter
      $response = (Invoke-Rsc $query).nodes
      # since there is no exact match
      Write-Verbose -Message "Matching $Name exactly"
      $response = $response | where {$_.name -eq "$Name"}
    } elseif ($PSBoundParameters['Id']) {
      <#
      # The following code is preferred, however is not currently working due to a bug in the SDK with the slaDomain GQL query implementing Cluster and Global SLAs
      # Will comment out for now and use the original way of handcrafting the GQL queries...
      $query = New-RscQuery -GqlQuery slaDomain
      $query.var.id = $Id
      $response = Invoke-Rsc $query
      #>
      $variables = @{
        "id" = "$Id"
      }
      $response = Invoke-RubrikGQLRequest -query "slaDomainSingle" -variables $variables | ConvertFrom-Json 
      $response = $response.data.q
    }
    else {
      $query = New-RscQuery -GqlQuery slaDomains
      $response = (Invoke-Rsc $query).nodes
    }

  return $response
}