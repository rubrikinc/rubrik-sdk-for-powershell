function Get-RubrikRSCFileset {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    Param(
      # Name of the fileset
      [Parameter(
        ParameterSetName='Query',
        Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Fileset')]
      [String]$Name,
      [Parameter(ParameterSetName='Filter')]
      [ValidateNotNullOrEmpty()]
      [String]$NameFilter,
      # Exact name of the host using a fileset
      [Parameter(ParameterSetName='Query')]
      [Alias('host_name')]
      [ValidateNotNullOrEmpty()]
      # Partial match of hostname, using an 'in fix' search.
      [String]$HostName,
      [Parameter(ParameterSetName='Filter')]
      [ValidateNotNullOrEmpty()]
      [String]$HostNameFilter,
      # Rubrik's fileset id
      [Parameter(ParameterSetName='ID')]
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [ValidateNotNullOrEmpty()]
      [String]$id,
      # Filter results to include only relic (removed) filesets
      [Alias('is_relic')]
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Switch]$Relic,
      # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full Fileset object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [switch]$DetailedObject,
      # SLA Domain policy assigned to the database
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [ValidateNotNullOrEmpty()]
      [String]$SLA,
      # Filter the summary information based on the ID of a fileset template.
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Alias('template_id')]
      [ValidateNotNullOrEmpty()]
      [String]$TemplateID,
      # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Alias('primary_cluster_id')]
      [ValidateNotNullOrEmpty()]
      [String]$PrimaryClusterID,
      # Rubrik's Share id
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Alias('share_id')]
      [ValidateNotNullOrEmpty()]
      [String]$ShareID,
      # SLA id value
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Alias('effective_sla_domain_id')]
      [ValidateNotNullOrEmpty()]
      [String]$SLAID,
      # Rubrik server IP or FQDN
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Parameter(ParameterSetName='ID')]
      [String]$Server = $global:RubrikConnection.server,
      # API version
      [Parameter(ParameterSetName='Query')]
      [Parameter(ParameterSetName='Filter')]
      [Parameter(ParameterSetName='ID')]
      [String]$api = $global:RubrikConnection.api
    )


    if ($Id) {
        $query = New-RSCQuery -GqlQuery filesetTemplate
        $query.Var.fid = "$Id"
        $query.field.nodes[0].includes = "FETCH"
        <#
        # Populate Additional fields to fetch
        # For Example 
        $query.field.nodes[1].ProtectedObjectCount = 0
        #>
        
        $response = Invoke-RSC $query
      }

      return $response.nodes





}